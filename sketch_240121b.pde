class Field {
    int cols, rows, ind;
    PVector[][] fvals;

    Field(int rad) {
        ind = rad; cols = width / rad; rows = height / rad;
        fvals = new PVector[cols][rows]; init();
    }

    void init() {
        for (int i = 0; i < cols; i++)
            for (int j = 0; j < rows; j++)
                fvals[i][j] = PVector.random2D();
    }

    void make(PVector cur, PVector oth) {
        PVector tmp = oth.get(); tmp.normalize();
        fvals[int(constrain(cur.x / ind, 0, cols - 1))][int(constrain(cur.y / ind, 0, rows - 1))] = tmp;
    }

    PVector next(PVector next) {
        return fvals[int(constrain(next.x / ind, 0, cols - 1))][int(constrain(next.y / ind, 0, rows - 1))];
    }
}

class Line {
    PVector position, velocity, accel, nxt_v, nxt_pos, temp;
    float max_v, fut_f, cur_angle, rad, vel_rand = random(1);
    color cur_color = 0;

    Line(PVector position) {
        this.position = position;
        velocity = new PVector(0, 0);
        accel = new PVector(0, 0);

        rad = 4;
        max_v = vel_min + vel_rand * vel_max - vel_rand * vel_min;
        fut_f = f_min + vel_rand * f_max - vel_rand * f_min;
    }

    void update() {
        temp = position.get();
        velocity.add(accel);
        position.add(velocity);
        velocity.limit(max_v);
        accel.mult(0);
        cur_angle = velocity.heading();
    }

    void nxt_position() {
        nxt_v = velocity.get();
        nxt_v.normalize();
        nxt_v.mult(2);
        nxt_pos = PVector.add(nxt_v, position);
    }

    void follow(Field flow) {
        PVector fo = flow.next(nxt_pos);
        fo.mult(max_v);
        
        PVector st = PVector.sub(fo, velocity);
        st.limit(fut_f); accel.add(st);
    }

    void find(PVector target) {
        PVector fo = PVector.sub(target, position);
        fo.normalize(); fo.mult(max_v);
        
        PVector st = PVector.sub(fo, velocity);
        st.limit(fut_f); accel.add(st);
    }

    void get_edge() {
        if (-position.x > rad) position.x = rad + width;
        if (-position.y > rad) position.y = rad + height;
        if (position.x > width + rad) position.x = -rad;
        if (position.y > height + rad) position.y = -rad;
    }

    void next_state(Field fa, Field fb) {
        nxt_position(); follow(fa);
        fb.make(position, velocity);
        update(); get_edge();

        stroke(cur_color, 50);
        if (temp.dist(position) < 50)
            line(temp.x, temp.y, position.x, position.y);
    }
}

ArrayList<Line> batch1, batch2;
float vel_min = 3, vel_max = 6, f_min = 0.5, f_max = 5;

Field field1, field2;
PImage preload;

void setup() {
    size(1920, 1080, P2D);  // change according to monitor size
    background(0);

    field1 = new Field(3); field2 = new Field(4);
    batch1 = new ArrayList<Line>(); batch2 = new ArrayList<Line>();

    preload = loadImage("test.png");
    preload.loadPixels();

    for (int i = 0; i < 1e5; i++) {
        PVector position = new PVector(random(width), random(height));

        Line a = new Line(position);
        a.cur_color = preload.get(int(position.x / 2.5), (int) int(position.y / 2));  // manually divide

        batch1.add(a);
    }

    for (int i = 0; i < 2e4; i++) {
        PVector pos1 = new PVector(random(width), random(height));

        Line a1 = new Line(pos1);
        a1.cur_color = color(200, brightness(preload.get(int(pos1.x / 2.5), int(pos1.y / 2))));  // manually divide

        batch2.add(a1);
    }
}

void draw() {
    noStroke();
    fill(0, 5); rect(0, 0, width, height);
    for (Line b: batch2) b.next_state(field2, field2);
    for (Line b: batch1) b.next_state(field2, field1);
    for (Line b: batch2) b.next_state(field2, field2);
}
