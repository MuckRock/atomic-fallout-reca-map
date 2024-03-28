<script>
  import { onMount } from "svelte";
  import maplibregl from "maplibre-gl";
  import * as pmtiles from "pmtiles";
  import layers from "protomaps-themes-base";

  import text from "./text.json";
  import reca from "./data/reca.json";

  const TILE_URL =
    "https://muckrock-tiles.s3.amazonaws.com/planet/20240103.pmtiles";

  const protocol = new pmtiles.Protocol();

  maplibregl.addProtocol("pmtiles", protocol.tile);

  let container;
  let map;
  let visible = "uranium";
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

          reca: {
            type: "geojson",
            data: reca,
          },
        },
        layers: layers("protomaps", "light"),
      },
      center: [-110.79, 41.17],
      zoom: 3.25,
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

    map.addLayer(
      {
        id: "reca-lines",
        source: "reca",
        type: "line",
        paint: {
          "line-color": ["get", "fill"],
          "line-opacity": 0.75,
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
  <h1>{@html text.headline}</h1>
</header>

<div bind:this={container} class="container">
  <noscript> This experience requires JavaScript to function. </noscript>
</div>

<footer>
  <label>
    Highlight
    <select bind:value={visible}>
      {#each text.legend.items as { color, value, label }}
        <option {value} style:color>
          {label}
        </option>
      {/each}
    </select>
  </label>
  <p>
    {text.legend.description}
  </p>
  <div class="source">
    <p>Source: {text.source}</p>
  </div>
</footer>

<style>
  :global(#app) {
    display: flex;
    flex-flow: column nowrap;
    font-family:
      "Source Sans Pro",
      -apple-system,
      "system-ui",
      "Segoe UI",
      Roboto,
      Oxygen,
      Ubuntu,
      Cantarell,
      "Fira Sans",
      "Droid Sans",
      "Helvetica Neue",
      sans-serif;
  }

  header {
    background-color: black;
    display: flex;
    flex: none;
    justify-content: space-between;
    padding: 0.5em 1rem;
    z-index: 10;
  }

  header h1 {
    color: white;
    font-size: 1.5rem;
    margin: 0;
  }

  header :global(a) {
    color: white;
    text-decoration: underline;
  }

  .container {
    flex: 1 1 10rem;
  }

  footer {
    font-size: 1rem;
    padding: 1rem;
    max-width: 100ch;
    margin: 0 auto;
  }

  footer label {
    font-weight: bold;
    display: flex;
    gap: 1rem;
  }

  footer label,
  footer select,
  footer option {
    font-size: 1rem;
  }
</style>
