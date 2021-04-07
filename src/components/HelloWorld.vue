<template>
  <v-container>
    <!--
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
          <td v-for="lang in langs_selected" :key="lang"> {{ $data[lang][item] }} </td>
        </tr>
        </tbody>
      </template>
    </v-simple-table>
    -->

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

    <!-- TABLE WITH TAGS TO TRANSLATE -->
    <template>
      <v-data-table
          dense
          :headers="headers"
          :items="data_to_translate"
          :items-per-page="20"
          class="elevation-1"
      >
        <!--<template v-slot:top>
          <v-btn @click="translate">Translate</v-btn>
        </template>-->
        <template v-for="lang in langs_selected" v-slot:$data[lang]="props">
          <v-text-field v-model="props.$data[lang]"></v-text-field>
        </template>
      </v-data-table>
    </template>
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

    created: function() {
      this.read_language_file('ar')
      this.read_language_file('de')
      this.read_language_file('en')
      this.read_language_file('es')
      this.read_language_file('fr')
      this.read_language_file('th')

    },

    methods: {
      read_language_file(lan) {
        //Return content of /languages/lan.json
        let url = '/languages/'+lan+'.json'
        axios.get(url)
            .then(response => (this[lan] = response.data))
      },
      tags_not_in(lan1, lan2){
        let _this = this
        //Return the tags from lan1 not included in lan2
        let tags1 = Object.keys(_this[lan1])
        let tags2 = Object.keys(_this[lan2])

        let difference = tags1.filter(x => !tags2.includes(x));
        return difference
      },
      missing_tags(){
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
      },
      translate() {
        /*const items = [...this.]

        // deep copy is the solution
        // const items = JSON.parse(JSON.stringify(this.customer.items))

        items.map(item => {
          item.qty2 = ''
          return item
        })
        this.items = items*/
      }

    },
    computed: {
      headers () {
        let header = [
          {
            text: 'TAG',
            align: 'start',
            sortable: false,
            value: 'tag',
          },
          { text: 'ENGLISH', value: 'en'}
        ];

        this.langs_selected.forEach(lang_key => {
          let lang = this.key_to_language(lang_key).toUpperCase();
          let obj = { text: lang, value: lang_key};
          header.push(obj);
        });

        return header
      },
      data_to_translate() {
        let data_for_table = [];
        this.missing_tags().forEach(tag => {
          let obj = {
            tag: tag,
            en: this.en[tag],
          };
          this.langs_selected.forEach(lang_key => {
            obj[lang_key] = this.$data[lang_key][tag];
          });
          data_for_table.push(obj);
        });

        return data_for_table;
      }
    },
  }
</script>
