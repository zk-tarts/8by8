
<script>
import ColourPicker from "./ColourPicker.svelte";

    let canvas
    import { chain, izip  } from "./itertools";
    let selected = "colour0"
    let colours = new Map([["colour0","#000000"],["colour1","#1b1b1b"],["colour2","#9c9c9c"],["colour3","#afafaf"]])
    $: colour = colours.get(selected)
	
    let hex="colour all tiles"

    function mouse_draw(e) {
        if (e.buttons != 1) {
            return
        }
        draw(e.target)
        calculate()
    }

    function draw(pix) {
        if (!pix.childElementCount) { // stops fill when border clicked
            pix.style.background=colour
            pix.setAttribute("c", selected)
        }
    }

    function change_col(e) {
        selected = e.target.id
    }

    function repaint() {
        colour=colours.get(selected) // I don't know why but this needs to be here
        for (const child of canvas.children) {
            if (child.getAttribute("c") == selected) {
                draw(child)
            }
        }
    }

    function pick(e) {
        colours.set(selected,e.detail.colour)
        colours=colours
        repaint()
        calculate()
    }


    function color_to_num(col) {
        return parseInt(col[col.length-1]) // change color to number by getting last char
    }

    
    // don't know if this generator stuff is better than working with arrays but I think its COOLER!!
    function* get_split_canvas() {
        // changes all colour to numbers
        function* num_iter() {
            for (const child of canvas.children) { // from top left to bottom right
                yield color_to_num(child.getAttribute("c"))
            }   
        }

        for (const num of num_iter()) {
            yield [num&1,(num>>1)&1] 
        }
    }

    function* bit_iter_to_hex(bits) {
        // every 4 bits, collect into one hex char
        // why not do it all at once? This preserves the leading zeroes
        let i = 1;
        let tmp = []
        for (const bit of bits) {
            tmp.push(bit)
            if (i%4==0) {
                let binaryString = tmp.join("")
                yield parseInt(binaryString,2).toString(16)
                tmp=[]
            }
            i++
        }
    }

    function calculate() {
        for (const child of canvas.children) {
            if (!child.getAttribute("c")) {
                return
            }
        }
        let x = get_split_canvas()
        let prefix_removed_colours =  [...colours.values()].map(str=>str.slice(1)).join("")
        hex = "0x"+ [...bit_iter_to_hex(chain(...izip(...x)))].join("") + prefix_removed_colours
    }

</script>

<h3>{hex}</h3>
<div class="container">
    <div class="pcanvas" on:dragstart={e=>e.preventDefault()} on:pointerdown={mouse_draw} on:pointermove={mouse_draw} bind:this={canvas}>
        <div/><div/><div/><div/><div/><div/><div/><div/>
        <div/><div/><div/><div/><div/><div/><div/><div/>
        <div/><div/><div/><div/><div/><div/><div/><div/>
        <div/><div/><div/><div/><div/><div/><div/><div/>
        <div/><div/><div/><div/><div/><div/><div/><div/>
        <div/><div/><div/><div/><div/><div/><div/><div/>
        <div/><div/><div/><div/><div/><div/><div/><div/>
        <div/><div/><div/><div/><div/><div/><div/><div/>
    </div>
    <div class="colourbuttons">
        <button id="colour0" class="colourButton" on:click={change_col}>0</button>
        <button id="colour1" class="colourButton" on:click={change_col}>1</button>
        <button id="colour2" class="colourButton" on:click={change_col}>2</button>
        <button id="colour3" class="colourButton" on:click={change_col}>3</button>
    </div>
</div>
<div class="pick">
    <ColourPicker on:pick={pick}/> 
</div>

<style>
.container {
    display: flex;
    flex-direction: column;
    margin: 20%
}
.pcanvas {
    outline: 0.4rem groove black;
    margin: 10%;
    grid-template: repeat(8,1fr) / repeat(8,1fr);
    display: grid;
}
.pcanvas>* {
    aspect-ratio: 1 / 1;	
}
.colourbuttons {
    display: grid;
    grid-template-columns: repeat(4,1fr);
    justify-items: center;
}
.colourButton {
    width: 60%;
} 
.pick {
    display: flex;
    justify-content: center;
}

</style>