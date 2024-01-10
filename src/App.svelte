<script>
  import { onMount } from "svelte";
  import maplibregl from "maplibre-gl";
  import * as pmtiles from "pmtiles";
  import layers from "protomaps-themes-base";

  import Legend from "./Legend.svelte";
  import text from "./text.json";
  import reca from "./data/reca.json";

  const TILE_URL =
    "https://muckrock-tiles.s3.amazonaws.com/planet/20240103.pmtiles";

  const protocol = new pmtiles.Protocol();

  maplibregl.addProtocol("pmtiles", protocol.tile);

  let container;
  let map;
  let visible = "all";
  let loaded = false;

  $: filter(map, visible, loaded);

  onMount(() => {
    map = new maplibregl.Map({
      container,
      style: {
        version: 8,
        glyphs:
          "https://protomaps.github.io/basemaps-assets/fonts/{fontstack}/{range}.pbf",
        sources: {
          protomaps: {
            type: "vector",
            url: "pmtiles://" + TILE_URL,
            attribution:
              '<a href="https://protomaps.com">Protomaps</a> © <a href="https://openstreetmap.org">OpenStreetMap</a>',
          },
        },
        layers: layers("protomaps", "light"),
      },
      center: [-101.56660156843634, 39.27531259430637],
      zoom: 4,
      hash: true,
    });

    // controls
    map.addControl(new maplibregl.NavigationControl(), "top-left");
    map.addControl(new maplibregl.FullscreenControl(), "top-left");

    map.once("load", onLoad);

    // for debugging
    window["map"] = map;
  });

  function onLoad(e) {
    const map = e.target;

    const firstSymbolLayer = map
      .getStyle()
      .layers.find((layer) => layer.type === "symbol");

    map.addSource("reca", { type: "geojson", data: reca });

    map.addLayer(
      {
        id: "reca-fill",
        source: "reca",
        type: "fill",
        layout: {},
        paint: {
          "fill-color": ["get", "fill"],
          "fill-opacity": 0.5,
        },
      },
      firstSymbolLayer.id
    );

    loaded = true;
  }

  function filter(map, visible, loaded) {
    if (!map || !loaded) return;

    // setting "all" clears filters
    const expression =
      visible === "all" ? null : ["==", ["get", "layer"], visible];

    map.setFilter("reca-fill", expression);
  }
</script>

<header>
  <h1>{text.headline}</h1>
</header>

<div bind:this={container} class="container">
  <noscript> This experience requires JavaScript to function. </noscript>
</div>

{#if map}
  <Legend {map}>
    <h2>{text.legend.title}</h2>
    <p>
      {text.legend.description}
    </p>

    <ol>
      <li class:selected={visible === "all"}>
        <label>
          <input type="radio" value="all" bind:group={visible} />
          <span>Show all</span>
        </label>
      </li>
      {#each text.legend.items as { color, label, value }}
        <li class:selected={visible.toString() === value.toString()}>
          <label>
            <input type="radio" {value} bind:group={visible} />
            <div class="box" style:background-color={color}></div>
            <span>{label}</span>
          </label>
        </li>
      {/each}
    </ol>
  </Legend>
{/if}

<style>
  :global(#app) {
    display: flex;
    flex-flow: column nowrap;
  }

  header {
    background-color: black;
    flex: none;
    padding: 0.5em 1em;
    z-index: 10;
  }

  header h1 {
    color: white;
    font-size: 1.5em;
    margin: 0;
  }

  .container {
    flex: 1 1 10em;
  }

  :global(.legend) p,
  :global(.legend) li {
    font-size: 14px;
  }

  :global(.legend) ol {
    padding: 0;
  }

  :global(.legend) ol li {
    list-style: none;
    margin-bottom: 0.25em;
  }

  :global(.legend) ol li label {
    border: 1px solid transparent;
    border-radius: 5px;
    cursor: pointer;
    display: flex;
    gap: 0.5em;
    padding: 0.25em;
  }

  :global(.legend) ol li label:hover {
    border: 1px solid rgba(255, 255, 255, 0.5);
  }

  :global(.legend) ol li.selected label {
    border: 1px solid #ddd;
  }

  :global(.legend) ol li label input {
    display: none;
  }

  :global(.legend) ol li .box {
    display: inline-block;
    height: 1.25em;
    width: 2ch;
  }

  :global(.legend.dark) .box {
    border: 0.5px solid white;
  }
</style>
