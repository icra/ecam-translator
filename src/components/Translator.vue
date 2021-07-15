<template>
  <v-container>

    <div id="import_file" class="mt-7 mb-7">
      <v-row class="mt-4 mr-4 ml-4">
        <v-col >
          <strong>Import language file from your computer (optional step):</strong>
        </v-col>
      </v-row>
      <v-row class="mr-4 ml-4">
        <v-col cols="6" md="5">
          <v-select
              :items="langs_to_import"
              v-model="import_language_model"
              label="Language of the file to import"
              item-text="state"
              item-value="abbr"
          ></v-select>
        </v-col>
        <v-col cols="6" md="5">
          <v-file-input
              accept="application/JSON"
              label="File input"
              :disabled='import_language_model == null'
              v-model="chosenFile"
          ></v-file-input>
        </v-col>
        <v-col cols="2" class="mt-3">
          <v-btn
              color="#2b6488"
              class="white--text"
              @click="import_translation"
              :disabled='chosenFile == null'
          >
            Import
            <v-icon
                right
                dark
            >
              mdi-cloud-upload
            </v-icon>
          </v-btn>
        </v-col>
      </v-row>
    </div>


    <!-- CHECKBOX TO SELECT LANGUAGES -->
    <v-row align-content="center">
      <v-col cols="auto" align-self="center">
        <strong>Select the language(s) you want to translate:</strong>
      </v-col>
      <v-col cols="auto" v-for="lang in langs_to_import">
        <v-checkbox
            v-model="langs_selected"
            :label="lang.state"
            :value="lang.abbr"
        ></v-checkbox>
      </v-col>
    </v-row>

    <v-row align-content="center" class="no-gutters">
      <v-col cols="auto">
        <v-checkbox
            v-model="contracted_table"
            label="Show only the words to translate"
        ></v-checkbox>
      </v-col>
    </v-row>

    <!-- TABLE WITH TAGS TO TRANSLATE -->
    <template>
      <v-card>
        <v-card-title v-if="langs_selected.length > 0">
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
                v-else
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

    <v-snackbar
        v-model="snackbar"
        :timeout="timeout"
        :color="color"
    >
      {{ text }}

      <v-icon v-if="error"
          dark
          right
          class="float-right"
      >
        mdi-alert-circle-outline
      </v-icon>
      <v-icon v-else
              dark
              right
              class="float-right"
      >
        mdi-checkbox-marked-circle
      </v-icon>

    </v-snackbar>

  </v-container>

</template>
<script>
  import axios from 'axios'
  import _ from 'lodash';

  export default {
    name: 'HelloWorld',

    data: () => ({
      data_for_table: [], //Totes les tags en tots els idiomes (tinguin o no traduccio)
      data_to_show: [], //Info per mostrar a la taula
      langs_selected: [],
      search: '',
      contracted_table: true,
      langs_filtered: null,

      //For manually importing file
      langs_to_import: [
        { state: 'Arabic', abbr: 'ar' },
        { state: 'French', abbr: 'fr' },
        { state: 'German', abbr: 'de' },
        { state: 'Spanish', abbr: 'es' },
        { state: 'Thai', abbr: 'th' },
        { state: 'Polish', abbr: 'pl' },

      ],
      import_language_model: null, //language to import
      chosenFile: null, //file to read

      //Snackbar props
      snackbar: false,
      text: '',
      timeout: 2000,
      color: 'green',
      error: true
    }),

    created: async function() {
      //Reading files
      let [ar, de, en, es, fr, th, pl] = await Promise.all([
        this.read_language_file('ar'),
        this.read_language_file('de'),
        this.read_language_file('en'),
        this.read_language_file('es'),
        this.read_language_file('fr'),
        this.read_language_file('th'),
        this.read_language_file('pl')
      ])


      let langs = {
        'ar': ar,
        'de': de,
        'es': es,
        'fr': fr,
        'th': th,
        'en': en,
        'pl': pl
      }
      this.filter_table(langs)

      this.langs_filtered = langs

    },

    methods: {
      filter_table(langs){
        let ar = langs['ar']
        let de = langs['de']
        let es = langs['es']
        let fr = langs['fr']
        let th = langs['th']
        let en = langs['en']
        let pl = langs['pl']

        //Deleting tags that aren't in the english file
        this.delete_tags_not_in(ar, en)
        this.delete_tags_not_in(de, en)
        this.delete_tags_not_in(es, en)
        this.delete_tags_not_in(fr, en)
        this.delete_tags_not_in(th, en)
        this.delete_tags_not_in(pl, en)


        //Preparing data for table
        let translation_with_lang_name = _.zip([ar, de, es, fr, th, pl],['ar', 'de', 'es', 'fr', 'th', 'pl'])
        this.data_for_table = this.data_to_translate(translation_with_lang_name, [en, 'en'])

      },

      read_language_file(lan) {
        //Return content of https://raw.githubusercontent.com/icra/ecam/master/frontend/languages/lan.json
        let url = 'https://raw.githubusercontent.com/icra/ecam/master/frontend/languages/'+lan+'.json'
        return axios.get(url).then(resp => {
          return resp.data
        }).catch(function (error) {
          return {}
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
          case "en":
            return "English"
          case "pl":
            return "Polish"
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

        let _this = this

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
      },
      async fileToJSON(file) {
        return new Promise((resolve, reject) => {
          const fileReader = new FileReader()
          fileReader.onload = event => resolve(JSON.parse(event.target.result))
          fileReader.onerror = error => reject(error)
          fileReader.readAsText(file)
        })
      },
      async import_translation() {
        let _this = this
        try {
          let json = await this.fileToJSON(this.chosenFile)

          //Snackbar
          this.snackbar = true
          this.text = 'Translation file imported correctly'
          this.color = 'rgb(34,139,34)'
          this.error = false

          //Table data
          this.data_for_table.forEach( item => {
            if(json.hasOwnProperty(item.tag)){
              item[this.import_language_model] = json[item.tag]
              this.langs_filtered[this.import_language_model][item.tag] = json[item.tag]
            }else{
              item[this.import_language_model] = ''
            }
          })

        } catch (e) {
          this.snackbar = true
          this.text = 'Error importing translation file'
          this.color = '#AF0606'
          this.error = true
        }

      }
    },

    watch: {
      langs_selected: function (val) {
        let _this = this
        let langs = val.map(lang => {
          return _this.langs_filtered[lang]
        })

        let english = _this.langs_filtered.en
        let missing_tags = _this.missing_tags(langs, english) //Cadascuna dels tags que està en anglès i no en algun dels lang_selected

        let data_for_table = []
        missing_tags.forEach(tag => {
          let new_word = {
            tag: tag,
            en: english[tag]
          }

          let item =  _this.data_for_table.find(item => {
            return item.tag === tag
          })
          /*
          console.log(item)

          val.forEach(lang => {
            new_word[lang] = item[lang]
          })*/

          data_for_table.push(item)
        })

        _this.data_to_show = data_for_table

      },
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
                width: '25%',
                fixed: true,
                class: 'tag_header'
              },
              {
                text: 'ENGLISH',
                value: 'en',
                width: '25%',
                fixed: true
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
        let _this = this;
        if(this.contracted_table){

          return this.data_to_show



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

  #import_file {
    border-style: solid;
    border-color: #2b6488;
    border-radius: 10px;
  }

  .v-card{
    overflow-wrap: anywhere!important;
  }

</style>
