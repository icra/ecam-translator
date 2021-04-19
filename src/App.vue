<template>
  <v-app>
    <v-app-bar
      app
      color="#2b6488"
      dark
      id="navbar"
    >
      <div>
        <a href="https://ecam.icradev.cat/" target="_blank" class="d-flex align-center" title="https://ecam.icradev.cat/">
          <div>
            <b id="logo">ECAM</b>
          </div>
          <div>Energy Performance and Carbon Emissions Assessment and Monitoring Tool</div>
        </a>
      </div>

      <v-spacer></v-spacer>

      <div>
        <b>TRANSLATION TOOL</b>
      </div>
    </v-app-bar>

    <v-main>
      <Translator/>
    </v-main>
  </v-app>
</template>

<script>
import Translator from './components/Translator';

export default {
  name: 'App',

  components: {
    Translator,
  },

  data: () => ({
    //
  }),
};
</script>

<style>
  #navbar #logo {
    font-size: 30px;
    line-height: 9%;
    margin: 5px 8px;
  }

  #navbar a{
    color: white;
    text-decoration: none;
  }

  a {
    font-weight: normal;
  }

</style>