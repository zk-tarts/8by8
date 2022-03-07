<script>
    import { createEventDispatcher } from 'svelte';
    const dispatch = createEventDispatcher()

    let [hue,sat,light] = [0,100,50]
    $: colour = hsl_to_rgbstring(hue,sat,light)

    // https://drafts.csswg.org/css-color/#hsl-to-rgb
    function hsl_to_rgbstring(h,s,l) {
        s /= 100
        l /= 100

        function f(n) {
            let k = (n + h/30) % 12
            let a = s * Math.min(l, 1-l)
            return l - a * Math.max(-1, Math.min(k - 3, 9 - k, 1))
        }
        let [r,g,b] = [f(0), f(8), f(4)]
 
        function a(n){
            let str = Math.round((255*n)).toString(16)
            if (str.length == 1) str = "0"+str
            return str 
        }
        return "#" + a(r) + a(g) + a(b)
    }

    function pick(e) {
        if (e.buttons != 1) return
        const size = e.target.clientWidth // the circle is circular so width = height
        const x = e.offsetX
        const y = e.offsetY

        let theta = Math.atan2(y - size/2, x - size/2)
        let h = (theta + 2*Math.PI + Math.PI/2) % (2*Math.PI) // rotate so red (0) is on top
        hue = h * (180/Math.PI)
        sat = Math.hypot(x - size/2, y - size/2) * (100/size) * 2
        dispatch('pick',{
            colour: colour
        })
    }


</script>
  
<div class="container" >
    <div class="wheel" on:pointerdown={pick} on:pointermove={pick} >
	    <div style="background: hsl(0,0%,{light}%)" />
    </div>
    <div class = "hsl" style="background:{colour}">
        <div>H:{Math.round(hue)}</div>
        <div>S:{Math.round(sat)}%</div>
        <div>L:{Math.round(light)}%</div>
    </div>
    <input type="range" name="lightness"min="0" max="100" bind:value={light}>
</div>


<style>
    .container {
        width: 200px;
        aspect-ratio: 1 / 1;
    }
	.wheel {
        background: radial-gradient(closest-side, #bcbcbc, transparent), conic-gradient(rgb(255,0,0), rgb(255,255,0), rgb(0,255,0), rgb(0,255,255), rgb(0,0,255), rgb(255,0,255), rgb(255,0,0)); 
    }
	.wheel, .wheel>*{
		aspect-ratio: 1 / 1;
		border-radius: 50%;
        mix-blend-mode: hard-light;
        min-height: 100%;
	}

    .hsl {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
    }


</style>
