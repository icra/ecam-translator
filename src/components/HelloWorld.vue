<template>
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
      </tr>
      </thead>
      <tbody>
      <tr
          v-for="item in tags_not_in('en', 'es')"
          :key="item"
      >
        <td>{{ item }}</td>
        <td>{{ en[item] }}</td>
      </tr>
      </tbody>
    </template>
  </v-simple-table>
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
      th: {}
    }),

    created: function() {
      this.read_language_file('es')
      this.read_language_file('en')
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
    },

  }
</script>
