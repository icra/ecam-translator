<template>
  <v-container>
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
    <div>
      <v-data-table
          :headers="headers"
          :items="desserts"
          item-key="name"
          class="elevation-1"
          :search="search"
          :custom-filter="filterOnlyCapsText"
      >
        <template v-slot:top>
          <v-text-field
              v-model="search"
              label="Search (UPPER CASE ONLY)"
              class="mx-4"
          ></v-text-field>
        </template>
        <template v-slot:body.append>
          <tr>
            <td></td>
            <td>
              <v-text-field
                  v-model="calories"
                  type="number"
                  label="Less than"
              ></v-text-field>
            </td>
            <td colspan="4"></td>
          </tr>
        </template>
      </v-data-table>
    </div>
  </v-container>

</template>

<script>
  export default {
    name: 'HelloWorld',

    data: () => ({
      langs_selected: [],
    }),
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
    methods: {
      filterOnlyCapsText (value, search, item) {
        return value != null &&
            search != null &&
            typeof value === 'string' &&
            value.toString().toLocaleUpperCase().indexOf(search) !== -1
      },
    },
  }
</script>
