<template>
  <v-container>

    <!-- CHECKBOX TO SELECT LANGUAGES -->
    <v-row align-content="center">
      <v-col cols="auto" align-self="center">
        <strong>Select the language(s) you want to translate:</strong>
      </v-col>
      <v-col cols="auto">
        <v-checkbox
            v-model="langs_selected"
            label="Arabic"
            value="ar"
        ></v-checkbox>
      </v-col>
      <v-col cols="auto">
        <v-checkbox
            v-model="langs_selected"
            label="French"
            value="fr"
        ></v-checkbox>
      </v-col>
      <v-col cols="auto">
        <v-checkbox
            v-model="langs_selected"
            label="German"
            value="de"
        ></v-checkbox>
      </v-col>
      <v-col cols="auto">
        <v-checkbox
            v-model="langs_selected"
            label="Spanish"
            value="es"
        ></v-checkbox>
      </v-col>
      <v-col cols="auto">
        <v-checkbox
            v-model="langs_selected"
            label="Thai"
            value="th"
        ></v-checkbox>
      </v-col>
    </v-row>

    <!-- TABLE WITH TAGS TO TRANSLATE -->
    <template>
      <v-card>
        <v-card-title>
          <v-text-field
              v-model="search"
              append-icon="mdi-magnify"
              label="Search"
              hide-details
          ></v-text-field>
        </v-card-title>

        <v-data-table
            dense
            :headers="headers"
            :items="data_for_table"
            :items-per-page="10"
            class="elevation-10 dataTable"
            :search="search"

        >
          <template v-for="lang in langs_selected" v-slot:[`item.${lang}`]="{ item }">
            <v-textarea
                rows="1"
                v-model="item[lang]">
            </v-textarea>
          </template>
        </v-data-table>
      </v-card>

    </template>
    <v-btn
        color="#2b6488"
        class="mt-10 white--text"
        @click="download_translations"
    >
      Download translations
      <v-icon
          right
          dark
      >
        mdi-cloud-download
      </v-icon>
    </v-btn>
  </v-container>

</template>
<script>
  import axios from 'axios'

  export default {
    name: 'HelloWorld',

    data: () => ({
      ar: {},
      de: {},
      en: {},
      es: {},
      fr: {},
      th: {},
      data_for_table: [],
      langs_selected: [],
      search: '',
    }),

    created: async function() {
      let [ar, de, en, es, fr, th] = await Promise.all([
        this.read_language_file('ar'),
        this.read_language_file('de'),
        this.read_language_file('en'),
        this.read_language_file('es'),
        this.read_language_file('fr'),
        this.read_language_file('th')
      ])
      this.ar = ar.data
      this.de = de.data
      this.en = en.data
      this.es = es.data
      this.fr = fr.data
      this.th = th.data
      this.delete_tags_not_in('ar', 'en')
      this.delete_tags_not_in('de', 'en')
      this.delete_tags_not_in('es', 'en')
      this.delete_tags_not_in('fr', 'en')
      this.delete_tags_not_in('th', 'en')
      this.data_for_table = this.data_to_translate()
    },

    methods: {
      read_language_file(lan) {
        //Return content of /languages/lan.json
        let url = '/languages/'+lan+'.json'
        return axios.get(url)
      },
      tags_not_in(lan1, lan2){
        //Return the tags from data.lan1 not included in data.lan2
        let tags1 = Object.keys(this[lan1])
        let tags2 = Object.keys(this[lan2])
        let difference = tags1.filter(x => !tags2.includes(x));
        return difference
      },
      delete_tags_not_in(lan1, lan2){
        //Delete tags from data.lan1 not included in data.lan2
        let _this = this
        let tags_to_delete = this.tags_not_in(lan1, lan2)
        tags_to_delete.forEach(tag => {
          delete _this[lan1][tag]
        })
      },
      missing_tags(langs){
        //return all the tags missing from this.langs_selected compared to this.en
        let missing_tags = new Set()
        langs.forEach(lang => {
          let lang_missing_tags = this.tags_not_in('en', lang)
          lang_missing_tags.forEach(missing_tags.add, missing_tags)
        })
        return [...missing_tags]
      },
      filterOnlyCapsText (value, search, item) {
        return value != null &&
            search != null &&
            typeof value === 'string' &&
            value.toString().toLocaleUpperCase().indexOf(search) !== -1
      },
      key_to_language (key) {
        switch (key) {
          case "ar":
            return "Arabic"
          case "fr":
            return "French"
          case "de":
            return "German"
          case "es":
            return "Spanish"
          case "th":
            return "Thai"
        }
      },
      download_translations () {
        console.log(this.data_for_table)
        this.langs_selected.forEach(lang => {
          let jsonObj = this[lang]
          let lan_translated = JSON.parse(JSON.stringify(jsonObj));
          this.data_for_table.forEach(translation => {
            let tag = translation['tag']
            let trans = translation[lang]
            if(trans != '') lan_translated[tag] = translation[lang]
          })
          this.downloadObjectAsJson(lan_translated, lang)
        })
      },
      downloadObjectAsJson(exportObj, exportName){
        let dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(exportObj));
        let downloadAnchorNode = document.createElement('a');
        downloadAnchorNode.setAttribute("href",     dataStr);
        downloadAnchorNode.setAttribute("download", exportName + ".json");
        document.body.appendChild(downloadAnchorNode); // required for firefox
        downloadAnchorNode.click();
        downloadAnchorNode.remove();
      },
      data_to_translate() {
        let data_for_table = [];

        this.missing_tags(['ar', 'de', 'es', 'fr', 'th']).forEach(tag => {
          let _this = this
          let current_languages = ['ar', 'de', 'en', 'es', 'fr', 'th']
          let obj = {
            tag: tag,
          };
          current_languages.forEach(lang_key => {
            if(_this[lang_key].hasOwnProperty(tag))
              obj[lang_key] = _this[lang_key][tag];
            else
              obj[lang_key] = '';
          })
          data_for_table.push(obj);
        });
        return data_for_table;
      }
    },
    computed: {
      headers () {
        let header = [];

        if(this.langs_selected.length > 0){
          header.push(
              {
                text: 'TAG',
                align: 'start',
                sortable: false,
                value: 'tag',
                width: '25%'
              },
              {
                text: 'ENGLISH',
                value: 'en',
                width: '25%'
              })
        }
        this.langs_selected.forEach(lang_key => {
          let lang = this.key_to_language(lang_key).toUpperCase();
          let obj = { text: lang, value: lang_key};
          header.push(obj);
        });

        return header
      },
    },
  }
</script>

<style>
  thead.v-data-table-header  {
    background-color: #2b6488 !important;
  }

  th.text-start {
    color: white !important;
  }

  .v-data-footer {
    background-color: lightgray;
  }



</style>