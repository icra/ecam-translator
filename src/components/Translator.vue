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

    <v-row align-content="center">
      <v-col cols="auto" align-self="center">
        <strong>Show only the words to translate:</strong>
      </v-col>
      <v-col cols="auto">
        <v-checkbox
            v-model="contracted_table"
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
            :items="data_info"
            :items-per-page="10"
            class="elevation-10 dataTable"
            :search="search"

        >
          <template v-for="lang in langs_selected" v-slot:[`item.${lang}`]="{ item }">
            <v-textarea
                v-if="lang !== 'ar'"
                rows="1"
                v-model="item[lang]">
            </v-textarea>
            <v-textarea
                v-if="lang === 'ar'"
                dir="auto"
                rows="1"
                v-model="item[lang]">
            </v-textarea>
          </template>
        </v-data-table>
      </v-card>

    </template>
    <v-btn
        color="#2b6488"
        class="my-10 white--text"
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
  import _ from 'lodash';

  export default {
    name: 'HelloWorld',

    data: () => ({
      data_for_table: [],
      langs_selected: [],
      search: '',
      contracted_table: true,
      initial_missing_tags: []  //Tags that need to be translated when the json files are read
    }),

    created: async function() {
      //Reading files
      let [ar, de, en, es, fr, th] = await Promise.all([
        this.read_language_file('ar'),
        this.read_language_file('de'),
        this.read_language_file('en'),
        this.read_language_file('es'),
        this.read_language_file('fr'),
        this.read_language_file('th')
      ])

      //Deleting tags that aren't in the english file
      this.delete_tags_not_in(ar, en)
      this.delete_tags_not_in(de, en)
      this.delete_tags_not_in(es, en)
      this.delete_tags_not_in(fr, en)
      this.delete_tags_not_in(th, en)

      //Tags that need to be translated
      this.initial_missing_tags =  this.missing_tags([ar, de, es, fr, th], en)

      //Preparing data for table
      let translation_with_lang_name = _.zip([ar, de, es, fr, th],['ar', 'de', 'es', 'fr', 'th'])
      this.data_for_table = this.data_to_translate(translation_with_lang_name, [en, 'en'])
    },

    methods: {
      read_language_file(lan) {
        //Return content of https://raw.githubusercontent.com/icra/ecam/v3/v3/frontend/languages/lan.json
        let url = 'https://raw.githubusercontent.com/icra/ecam/v3/v3/frontend/languages/'+lan+'.json'
        return axios.get(url).then(resp => {
          return resp.data
        })
      },
      tags_not_in(lan1, lan2){
        //Return the tags from lan1 not included in lan2
        let tags1 = Object.keys(lan1)
        let tags2 = Object.keys(lan2)
        let difference = tags1.filter(x => !tags2.includes(x));
        return difference
      },
      delete_tags_not_in(lan1, lan2){
        //Delete tags from lan1 not included in lan2
        let tags_to_delete = this.tags_not_in(lan1, lan2)
        tags_to_delete.forEach(tag => {
          delete lan1[tag]
        })
      },
      missing_tags(langs, master_lang){
        //return all the tags missing in langs compared to master_lang
        let missing_tags = new Set()
        langs.forEach(lang => {
          let lang_missing_tags = this.tags_not_in(master_lang, lang)
          lang_missing_tags.forEach(missing_tags.add, missing_tags)
        })
        return [...missing_tags]
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
        this.langs_selected.forEach(lang => {
          let lan_translated = {};
          this.data_for_table.forEach(translation => {
            let tag = translation['tag']
            let trans = translation[lang]
            if(trans !== '') lan_translated[tag] = translation[lang]
          })
          this.downloadObjectAsJson(lan_translated, lang)
        })
      },
      downloadObjectAsJson(exportObj, exportName){
        let dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(exportObj, null, '\t'));
        let downloadAnchorNode = document.createElement('a');
        downloadAnchorNode.setAttribute("href",     dataStr);
        downloadAnchorNode.setAttribute("download", exportName + ".json");
        document.body.appendChild(downloadAnchorNode); // required for firefox
        downloadAnchorNode.click();
        downloadAnchorNode.remove();
      },


      data_to_translate(data_to_translate, master_lang) {
        //data_to_translate is [[json, 'language key'],...], and master_lang is[json, 'language key']

        let data_for_table = [];

        Object.keys(master_lang[0]).forEach(tag => {
          let obj = {
            tag: tag,
            [master_lang[1]]: master_lang[0][tag]       //Translation in master language
          };

          data_to_translate.forEach(lang_translations => {
            let translation = lang_translations[0]
            let lang_key = lang_translations[1]

            if(translation.hasOwnProperty(tag))
              obj[lang_key] = translation[tag];
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
      data_info () {
        if(this.contracted_table){

          let filtered_table = []
          this.initial_missing_tags.forEach(tag => {
            filtered_table.push(
                this.data_for_table.find(function(item) {
                  return item.tag == tag
                })
            )
          })
          return filtered_table
        } else{
          return this.data_for_table
        }
      }
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