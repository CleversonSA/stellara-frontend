<template lang="pug">
  q-page(
    class="flex flex-center "
  )
    div(
      class="q-pa-md column items-start flex flex-center display"
    )
      q-card(
        class="mode"
      )
        q-card-actions(
         class="flex flex-center row"
        )
          q-btn(
             class="mode-btn"
             rounded
             glossy
             color="purple"
             label="Shortwave"
             :disable="(mode == 'hf')? true: false"
             @click.prevent="swapMode"
           )
          q-btn(
             class="mode-btn"
             rounded
             glossy
             color="purple"
             label="Vhf"
             :disable="(mode == 'vhf')? true: false"
             @click.prevent="swapMode"
           )
      q-card(
        class="player"
      )
        q-card-section
          q-media-player(
            type="audio"
            background-color="purple"
            radius="1rem"
            :sources="audio.sources"
          )
      q-card(
        class="frequency"
      )
        q-card-section
          div(
            class="text-h6"
          ) VFO Frequency
        q-separator
        q-card-section(
          class="flex flex-center"
        )
          div(
            class="text-h2 text-weight-medium"
          ) {{ frequency }}
        q-card-section
          q-linear-progress(
            size="25px"
            :value="smeter[smeterlevel]"
            stripe
            rounded
            color="accent"
          )
            div(
              class="absolute-full flex flex-center"
            )
              q-badge(
                color="white"
                text-color="accent"
                :label="smeterlevel"
              )
        q-separator
        q-card-actions(
          class="flex flex-center column"
        )
          div(
            class="row"
          )
            q-btn-toggle(
              v-model="freq_step"
              push
              glossy
              toggle-color="teal"
              :options="freq_steps"
            )
          div(
            class="row"
          )
            q-btn(
              class="frequency-btn"
              rounded
              glossy
              icon="arrow_upward"
              color="purple"
              @click.prevent="increaseFreq"
            )
            q-btn(
              class="frequency-btn"
              rounded
              glossy
              icon="arrow_downward"
              color="purple"
              @click.prevent="decreaseFreq"
            )
      q-card(
        class="modulation"
      )
        q-card-section
          div(
            class="text-h6"
          ) Modulation settings
        q-separator
        q-card-section
          q-select(
            rounded
            outlined
            bottom-slots
            v-model="modulation"
            :options="modulations"
            label="Modulation"
          )
            template(
              v-slot:before
            )
             q-icon(
               name="waves"
             )
          q-select(
            rounded
            outlined
            bottom-slots
            v-model="bandwidth"
            :options="bandwidths"
            label="Bandwidth"
          )
            template(
              v-slot:before
            )
             q-icon(
               name="settings_ethernet"
             )
      q-card(
        class="scanning"
      )
        q-card-section
          div(
            class="text-h6"
          ) Strong frequencies
        q-separator
        q-card-section
          q-list(
            bordered
            v-if="top10freqs.length > 0"
          )
            q-item(
              clickable v-ripple
              v-for="freq in top10freqs"
              :key="freq.freq"
              @click.prevent="listenTopFreq(freq.freq)"
            )
              q-item-section(
                avatar
              )
                q-icon(
                  color="primary"
                  name="sensors"
                )
              q-item-section {{ freq.freq }}
          div(
            class="text-h7"
            v-if="top10freqs.length == 0"
          ) Oops, no frequencies scanned
        q-card-actions(
         class="flex flex-center column"
        )
          q-btn(
             class="frequency-btn"
             rounded
             glossy
             icon="search"
             color="purple"
             @click.prevent="scanFreqs"
           )
</template>
<style scoped>
.smeter {
  width: 100%;
  margin: 0px 0px 10px 0px;
}
.frequency {
  width: 100%;
  margin: 0px 0px 10px 0px;
}
.modulation {
  width: 100%;
  margin: 0px 0px 10px 0px;
}
.player {
  width: 100%;
  margin: 0px 0px 10px 0px;
}
.mode {
  width: 100%;
  margin: 0px 0px 10px 0px;
}
.frequency-btn {
  margin: 20px 20px 0px 0px;
  width: 64px;
  height: 64px
}
.mode-btn {
  width: 128px;
  height: 64px
}
.scanning {
  width: 100%;
  margin: 0px 0px 10px 0px;
}
</style>
<script>
import lodash from 'lodash'

export default {
  name: 'PageIndex',
  data () {
    return {
      smeterHandler: undefined,
      freqHandler: undefined,
      mode: 'hf',
      audio: {
        sources: [
          {
            src: 'http://192.168.100.235:8888/stellara.ogg',
            type: 'audio/ogg'
          }
        ]
      },
      freq_step: 1000,
      freq_steps: [
        { label: '10 Mhz', value: 10000 },
        { label: '1 Mhz', value: 1000 },
        { label: '100 Khz', value: 100 },
        { label: '10 Khz', value: 10 },
        { label: '1 Khz', value: 1 },
        { label: '100 hz', value: 0.100 },
        { label: '10 hz', value: 0.01 }
      ],
      frequency: 7023,
      smeterlevel: 'S6',
      smeter: {
        S1: 0.1,
        S2: 0.2,
        S3: 0.3,
        S4: 0.4,
        S5: 0.5,
        S6: 0.6,
        S7: 0.7,
        S8: 0.8,
        S9: 0.9,
        'S9+10dB': 1
      },
      modulation: { label: 'AM', value: 'am' },
      bandwidth: { label: 'Narrow', value: 'narrow' },
      modulations: [
        { label: 'AM', value: 'am' },
        { label: 'Narrow FM', value: 'nfm' },
        { label: 'FM Stereo', value: 'fmstereo' },
        { label: 'FM Mono', value: 'fm' },
        { label: 'USB', value: 'usb' },
        { label: 'LSB', value: 'lsb' },
        { label: 'CW LSB', value: 'cwl' },
        { label: 'CW USB', value: 'cwu' }
      ],
      bandwidths: [
        { label: 'Narrow', value: 'narrow' },
        { label: 'Normal', value: 'normal' },
        { label: 'Wide', value: 'wide' }
      ],
      top10freqs: []
    }
  },
  methods: {
    getFreqOffset (scale) {
      for (const fstep in this.freq_steps) {
        if (fstep.label.toUpperCase() === scale) {
          return fstep.value
        }
      }
    },
    increaseFreq () {
      this.frequency = parseFloat(this.frequency) + parseFloat(this.freq_step)
      if (this.frequency >= 24000 && this.mode === 'hf') {
        this.frequency = 100
      } else if (this.frequency >= 2400000 && this.mode === 'vhf') {
        this.frequency = 100
      }
      this.frequency = parseFloat(this.frequency).toFixed(2)
    },
    decreaseFreq () {
      this.frequency = parseFloat(this.frequency) - parseFloat(this.freq_step)
      if (this.frequency <= 0) {
        this.frequency = 24000
      }
      this.frequency = parseFloat(this.frequency).toFixed(2)
    },
    startTimers () {
      /* this.freqHandler = setInterval(() => {
        this.syncFreq()
      }, 5000) */
      this.smeterHandler = setInterval(() => {
        this.updateSmeter()
      }, 2000)
    },
    async syncFreq () {
      try {
        const result = await this.$axios.get('/control/frequency')
        if (result.data.success) {
          this.frequency = (parseFloat(result.data.frequency) / 1000).toFixed(2)
        } else {
          console.error(result.data)
        }
      } catch (error) {
        console.error(error)
      }
    },
    stopTimers () {
      clearInterval(this.smeterHandler)
      // clearInterval(this.freqHandler)
    },
    async swapMode () {
      this.$q.loading.show({
        message: 'Changing GQRX profile, please wait 30s for be ready again<br/><span class="text-orange text-weight-bold">Hang on...</span>'
      })

      if (this.mode === 'vhf') {
        this.mode = 'hf'
      } else if (this.mode === 'hf') {
        this.mode = 'vhf'
      }
      this.stopTimers()
      try {
        const result = await this.$axios.post('/control/swap', {
          mode: this.mode
        })
        if (result.data.success) {
          setTimeout(async () => {
            this.$q.loading.hide()
            this.startTimers()
            if (this.mode === 'hf') {
              this.frequency = 7023
            } else if (this.mode === 'vhf') {
              this.frequency = 28074
            }
          }, 30000)
        } else {
          console.error(result.data)
        }
      } catch (error) {
        console.error(error)
      }
    },
    async updateSmeter () {
      try {
        const result = await this.$axios.get('/control/smeter')
        if (result.data.success) {
          this.smeterlevel = result.data.scale.smeter
        } else {
          console.error(result.data)
        }
      } catch (error) {
        console.error(error)
      }
    },
    async listenTopFreq (freq) {
      this.frequency = parseFloat(freq).toFixed(2)
    },
    async scanFreqs () {
      this.$q.loading.show({
        message: 'Scanning frequencies, please wait about 30s to complete Mhz verification<br/><span class="text-orange text-weight-bold">Hang on...</span>'
      })
      this.stopTimers()
      try {
        const mhz = Math.round(parseFloat(this.frequency) / 1000)
        this.top10freqs = []
        const result = await this.$axios.get(`/control/scan/${mhz}`)
        this.$q.loading.hide()
        if (result.data.success) {
          this.top10freqs = result.data.frequencies
        } else {
          console.error(result.data)
        }
        await this.sendFreqRadio()
        this.startTimers()
      } catch (error) {
        console.error(error)
      }
    },
    async sendFreqRadio () {
      const deb = lodash.debounce(async () => {
        try {
          const result = await this.$axios.post('/control/frequency',
            {
              frequency: this.frequency * 1000
            })
          if (!result.data.success) {
            console.error(result.data)
          }
        } catch (error) {
          console.error(error)
        }
      }, 1000)
      deb()
    },
    async sendModRadio () {
      try {
        const result = await this.$axios.post('/control/modulation',
          {
            mode: this.modulation.value,
            bandwidth: this.bandwidth.value
          })
        if (!result.data.success) {
          console.error(result.data)
        }
      } catch (error) {
        console.error(error)
      }
    }
  },
  async mounted () {
    this.smeterHandler = setInterval(() => {
      this.updateSmeter()
    }, 2000)
    /* this.freqHandler = setInterval(() => {
      this.syncFreq()
    }, 5000) */
    await this.sendFreqRadio()
    await this.sendModRadio()
  },
  watch: {
    async frequency (value) {
      await this.sendFreqRadio()
    },
    async modulation (value) {
      await this.sendModRadio()
    },
    async bandwidth (value) {
      await this.sendModRadio()
    }
  }
}
</script>
