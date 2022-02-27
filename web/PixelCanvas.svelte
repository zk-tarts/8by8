
<script>
    let canvas
    let selected = "colour1"
    let colours = new Map([["colour1","red"],["colour2","red"],["colour3","red"],["colour4","red"]])
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
            pix.setAttribute("class", selected)
        }
    }

    function change_col(e) {
        selected = e.target.id
    }

    function repaint() {
        colours.set(selected,"purple")
		colour=colours.get(selected) // I don't know why but this needs to be here
        for (const child of canvas.children) {
            if (child.getAttribute("class") == selected) {
                draw(child)
            }
        }
    }

</script>

<p on:click={repaint}>{selected} {colour}</p>
<div class="container">
    <div class="pcanvas" on:pointerdown={mouse_draw} on:pointermove={mouse_draw} bind:this={canvas}>
        <div/><div/><div/><div/><div/><div/><div/><div/>
        <div/><div/><div/><div/><div/><div/><div/><div/>
        <div/><div/><div/><div/><div/><div/><div/><div/>
        <div/><div/><div/><div/><div/><div/><div/><div/>
        <div/><div/><div/><div/><div/><div/><div/><div/>
        <div/><div/><div/><div/><div/><div/><div/><div/>
        <div/><div/><div/><div/><div/><div/><div/><div/>
        <div/><div/><div/><div/><div/><div/><div/><div/>
    </div>
    <div class="colourbuttons" >
        <button id="colour1" class="colourButton" on:click={change_col}>1</button>
        <button id="colour2" class="colourButton" on:click={change_col}>2</button>
        <button id="colour3" class="colourButton" on:click={change_col}>3</button>
        <button id="colour4" class="colourButton" on:click={change_col}>4</button>
    </div>
</div>

<style>
.container {
    height: 50%;
    width: 50%;
}
.pcanvas {
    border: 0.5rem solid black;
    height: 100%;
    grid-template-columns: 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr ;
    grid-template-rows: 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr ;
    gap: 0;
    display: grid;
}
.colourbuttons {
    display:grid;
    grid-template-columns: 1fr 1fr 1fr 1fr;
    justify-items: center;
}
.colourButton {
    min-width: 50%;
    min-height: 2rem;
} 
</style>