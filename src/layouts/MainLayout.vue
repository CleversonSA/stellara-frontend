<template lang="pug">
  q-layout(
    view="lHh Lpr lFf"
  )
    q-header(
      elevated
    )
      q-toolbar
        q-toolbar-title
          label Stellara SDR Station
        div
          span Stellara v{{ version }}
    q-page-container
      router-view
</template>

<script>
import { version } from '../../package.json'

export default {
  name: 'MainLayout',
  data () {
    return {
      version
    }
  }
}
</script>
