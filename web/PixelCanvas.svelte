
<script>
    let canvas
    let selected = "colour1"
    let colours = new Map([["colour1","#000"],["colour2","#000"],["colour3","#000"],["colour4","#000"]])
    $: colour = colours.get(selected)
	

    function mouse_draw(e) {
        if (e.buttons != 1) {
            return
        }
        draw(e.target)
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
        colours.set(selected,e.target.value)
        colours=colours
        repaint()
    }

</script>

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
        <button id="colour1" class="colourButton" on:click={change_col}>1</button>
        <button id="colour2" class="colourButton" on:click={change_col}>2</button>
        <button id="colour3" class="colourButton" on:click={change_col}>3</button>
        <button id="colour4" class="colourButton" on:click={change_col}>4</button>
    </div>
</div>
<div class="pick">
    <input type="color" on:change={pick}/> <!--TODO: put a nice looking colour picker here-->  
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
    display:grid;
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