
<script>
    import {ColourPicker} from './ColourPicker.svelte'
    let colour = "red"
    function mouse_draw(e) {
        if (e.buttons != 1) {
            return
        }
        draw(e.target)
    }

    function draw(pix){
        pix.style.background=colour
    }

    function change_col(e){
        e.target.id
    }
    
</script>

<div class="pcanvas" on:pointerdown={mouse_draw} on:pointermove={mouse_draw} >
    <div/><div/><div/><div/><div/><div/><div/><div/>
    <div/><div/><div/><div/><div/><div/><div/><div/>
    <div/><div/><div/><div/><div/><div/><div/><div/>
    <div/><div/><div/><div/><div/><div/><div/><div/>
    <div/><div/><div/><div/><div/><div/><div/><div/>
    <div/><div/><div/><div/><div/><div/><div/><div/>
    <div/><div/><div/><div/><div/><div/><div/><div/>
    <div/><div/><div/><div/><div/><div/><div/><div/>
</div>
<div class="colourbuttons" on:click={change_col}>
    <button id="colour1" class="colourButton"/>
    <button id="colour2" class="colourButton"/>
    <button id="colour3" class="colourButton"/>
    <button id="colour4" class="colourButton"/>
</div>
<ColourPicker c={colour}/>

<style>
    .pcanvas {
        min-height: 100%;
        grid-template-columns: 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr ;
        grid-template-rows: 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr ;
        gap: 0;
        display: grid;
    }
</style>