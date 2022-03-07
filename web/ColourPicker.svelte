<script>
    // rgb colour wheel goes like this
    // ff0000 -> ffff00 -> 00ff00 -> 00ffff -> 0000ff -> ff00ff -> ff0000
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher()

    let [h,s,l] = [0,0,0]
    let colour = "#fff"

    // https://drafts.csswg.org/css-color/#hsl-to-rgb
    function hsl_to_rgbstring(h,s,l) {
        h *= (180/Math.PI)
        s /= 100
        l /= 100

        function f(n) {
            let k = (n + h/30) % 12
            let a = s * Math.min(l, 1-l)
            return l - a * Math.max(-1, Math.min(k - 3, 9 - k, 1))
        }
        let [r,g,b] = [f(0), f(8), f(4)]
 
        function a(n){
            str = Math.floor((255*n)).toString(16)
            if (str.length == 1) str = "0"+str
            return str 
        }
        return "#" + a(r) + a(g) + a(b)
    }

    function pick(e) {
        const size = e.target.clientWidth // the circle is circular so width = height
        const x = e.offsetX
        const y = e.offsetY

        let theta = Math.atan2(y - size/2, x - size/2)
        theta = (theta + 2*Math.PI + Math.PI/2) % (2*Math.PI)
        hsl_to_rgbstring(theta,100,50)
        colour = `hsl(${theta}rad,100%,50%)` 
        dispatch('pick',{
            colour: colour
        })
    }
</script>
  
<div class="container" >
    <div class="wheel" on:pointerdown={pick} />
    <div class = "hsl" style="background:{colour}">
        <div>H:{h}</div>
        <div>S:{s}%</div>
        <div>L:{l}%</div>
    </div>
</div>


<style>
    .container {
        width: 200px;
        aspect-ratio: 1 /1 ;
    }
    .wheel {
        aspect-ratio: 1 /1 ;
        min-height: 100%;
        border-radius: 50%;
        background: conic-gradient(rgb(255,0,0), rgb(255,255,0), rgb(0,255,0), rgb(0,255,255), rgb(0,0,255), rgb(255,0,255), rgb(255,0,0));
    }
    .hsl {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
    }

</style>
