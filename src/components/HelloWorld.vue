<template>
  <v-container>
    <v-simple-table dense>
      <template v-slot:default>
        <thead>
        <tr>
          <th class="text-left">
            Tag
          </th>
          <th class="text-left">
            English
          </th>
          <th class="text-left" v-for="lang in langs_selected" :key="lang">
            {{ key_to_language(lang) }}
          </th>
        </tr>
        </thead>
        <tbody>
        <tr
            v-for="item in missing_tags()"
            :key="item"
        >
          <td>{{ item }}</td>
          <td>{{ en[item] }}</td>
          <td v-for="lang in langs_selected" :key="lang">
            a
          </td>
        </tr>
        </tbody>
      </template>
    </v-simple-table>

    <!-- CHECKBOX TO SELECT LANGUAGES -->
    <p>{{ langs_selected }}</p>
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
      langs_selected: [],
    }),

    created: async function() {
      //let ar = (await this.read_language_file('ar')).data
      //console.log(ar)
      //this.read_language_file('de')
      //this.read_language_file('en')
      //this.read_language_file('es')
      //this.read_language_file('fr')
      //this.read_language_file('th')
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
      missing_tags(){
        //return all the tags missing from this.langs_selected compared to this.en
        let missing_tags = new Set()
        this.langs_selected.forEach(lang => {
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
      }
    },

    computed: {
      headers () {
        // fer que consulti els langs_selected per afegir el header de l'idioma seleccionat.
        return [
          {
            text: 'ENGLISH',
            align: 'start',
            sortable: false,
            value: 'en',
          },
          {
            text: 'Calories',
            value: 'calories',
            filter: value => {
              if (!this.calories) return true

              return value < parseInt(this.calories)
            },
          },
          { text: 'Fat (g)', value: 'fat' },
          { text: 'Carbs (g)', value: 'carbs' },
          { text: 'Protein (g)', value: 'protein' },
          { text: 'Iron (%)', value: 'iron' },
        ]
      },
    },
  }
</script>
