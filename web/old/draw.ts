function init(){
    const c: HTMLCanvasElement = document.getElementById("canvas") as HTMLCanvasElement
    let ctx = c.getContext("2d")
    let coloured_by = new Map<string,string>()
    let colours = new Map<number,string>()

    let colour = ""
    let colour_id = "0"
    let prev_col = ""
    const m = document.getElementById("colours")
    const dim = c.width/8

    let prev_x : number
    let prev_y : number

    const output = document.getElementById("output")
    output.innerText = "0x"+"0".repeat(56)
    
    for (let child of m.children) {
        child.addEventListener("change",pick)
        child.addEventListener("click",pick)
    }
    
    for (let j =0; j<512;j+=64){
        for (let i =0; i<512;i+=64){
        coloured_by.set(i.toString()+" "+j.toString(),"0")
        }
    }

    document.getElementById("update").addEventListener("click",encode)

    c.addEventListener("mousemove",mouse_draw)
    c.addEventListener("mousedown",mouse_draw)

    function round_coords(x: number,y: number) {
        return [((x|(dim-1)) + 1 - dim), ((y|(dim-1)) + 1 - dim)]
    }

    function update_colour(e) {
        let to_colour = []
        for (let [k,v] of coloured_by) {
            if (v == e) {
                to_colour.push([k,v])
            }
        }
        let m = new Map<string,string>(to_colour)
        for (let [k,v] of m) {
            let [x,y] = k.split(" ")
            draw(round_coords(parseInt(x),parseInt(y)),e)
        }
    }

    function mouse_draw(e: MouseEvent) {
        if (e.buttons != 1) {
            return
        }
        draw(round_coords(e.offsetX,e.offsetY),colour_id)
    }

    function draw(coords: number[], col) {
        let [x,y] = coords
        if (x != prev_x || y != prev_y || col != prev_col) {
            let key = x.toString()+" "+y.toString()
            if (col != "eraser") {
                ctx.fillStyle=colour
                ctx.fillRect(x, y, dim, dim)
            }
            else{
                ctx.clearRect(x, y, dim, dim)
            }
            coloured_by.set(key,colour_id)
        }
        [prev_x, prev_y, prev_col] = [x,y,colour_id]
    }

    function pick(e) {
        if (e.target.name != "eraser") {
            colour_id = e.target.name
            colour = e.target.value
            colours.set(parseInt(colour_id,10), colour)
        }
        else {
            colour_id = e.target.id
            colour = "#000000"
        }
        update_colour(colour_id)
    }

    function fmt(row: number[]) {
        let sum = 0
        let n = 0
        let l = row.length-1
        for (let e of row) {
            sum+=e<<(l-n)
            n+=1
        }
        let r = sum.toString(16)
        if (r.length <2) r = "0"+r
        return r
    }

    function encode() {
        // loop over all pixels reverrse (bottom right to top left)
        // turn into number 1 row at a time (each row is 2 hex digits)
        let n=0
        let a = []
        let r = []
        for (const [_,v] of coloured_by) {
            r.push(v)
            if ((n%8) == 7){
                a.push(r)
                r=[]
            }
            n+=1
        }
        
        let c = Array.from(colours.values())
        c = c.map(e=>e.slice(1))
                
        let t ="0x"+(a.map(row=>fmt(row.map(e=>parseInt(e,10)&1))).join(''))
        +(a.map(row=>fmt(row.map(e=>(parseInt(e,10)&2)>>1))).join(''))
        + c.join('')

        if (t.length < output.innerText.length) {
            t= t + "0".repeat(output.innerText.length-t.length)
        }
        output.innerText = t
    }
}
