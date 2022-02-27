<script>
    // https://gitlab.gnome.org/GNOME/gimp/-/blob/master/modules/gimpcolorwheel.c
    let h,s,v
    let cx=50
    let cy=50
    let c="red"
    let theta=0
    function pick(e){
        let rgb= hsv_to_rgb(h,s,v)
        c= rgb
    }
    function rot(e){
        if (e.buttons===1) {
            let boxBoundingRect = e.target.getBoundingClientRect();
            let boxCenter= {
                x: boxBoundingRect.left + boxBoundingRect.width/2, 
                y: boxBoundingRect.top + boxBoundingRect.height/2
            };
            theta = Math.atan2(e.pageX - boxCenter.x, - (e.pageY - boxCenter.y) )*(180 / Math.PI);
        }
    }
    function hsv_to_rgb(h,s,v) {
        let chroma = (1 - Math.abs(2*l -1)) * s
        let Hprime =h/60
        let x = chroma * (1 - Math.abs(Hprime % 2 -1 ))
        let c // colours
        switch (int(Hprime)) {
            case 0:
                c=[chroma,x,0]
                break;
            case 1:
                c=[x,chroma,0]
                break;  
            case 2:
                c=[0,chroma,x]
                break;
            case 3:
                c=[0,x,c]
                break;
            case 4:
                c=[x,0,chroma]
                break;
            case 5:
                c=[chroma,0,x]
                break;
            default:
            // dont get here
                break;
        }
        let m = v-chroma
        return c.map(e=>e-m)
    }

</script>


<div class="picker" >
    <svg viewBox="0 0 100 100" >
        <defs>
            <polygon class="triangle" id="triangle" points="50,15 100,100 0,100"  transform ="rotate({theta},0,0), scale(.74,.74), translate(0,-22) " />
            
            <linearGradient id="g0" gradientTransform="rotate(90)">
                <stop offset="0%" stop-color="#000"/>
                <stop offset="100%"stop-color="rgba(0,0,0,0)"/>
            </linearGradient>
            <linearGradient id="g1" gradientTransform="rotate(30)">
                <stop offset="0%" stop-color="#fff"/>
                <stop offset="100%" stop-color="rgba(255,255,255,0)"/>
            </linearGradient>
            <linearGradient id="g2" class="colour_t" gradientTransform="rotate(-30)">
                <stop offset="0%" stop-color={c}/>
                <stop offset="100%" stop-color={c}/>
            </linearGradient>
        
        </defs>
        <foreignObject width=100 height=100 x=0 y=0>
            <div class="whl" on:pointerdown={rot} />
        </foreignObject>
        <g class="tri">
            <use href="#triangle" fill="url('#g0')"/>
            <use href="#triangle" fill="url('#g1')"/>
            <use href="#triangle" fill="url('#g2')"/>
        </g>
        <circle cx={cx} cy={cy} r="1" fill="none" stroke="#000"/>
    </svg>
</div>


<style>
    .tri{
        isolation: isolate;
    }
    .colour_t {
        mix-blend-mode: hue;
    }
    .whl {
        min-height: 100%;
        border-radius: 50%;
        background: conic-gradient(rgb(255,0,0),rgb(255,255,0), rgb(0,255,0), rgb(0,255,255), rgb(0,0,255), rgb(255,0,255), rgb(255,0,0));
        clip-path: path("M 50 0 a 50 50 0 0 1 0 100 50 50 0 0 1 0 -100 v 8 a 42 42 0 0 0 0 84 42 42 0 0 0 0 -84");
    }

    .triangle {
        transform-origin: center;
    }
    .picker {
        width: 400px;
    }

</style>
