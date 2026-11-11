package com.radiowah.radio_wah

import com.ryanheise.audioservice.AudioServiceActivity

// AudioServiceActivity condivide il motore Flutter con il servizio audio:
// la musica continua a schermo spento e Android Auto pilota lo stesso player.
class MainActivity : AudioServiceActivity()
