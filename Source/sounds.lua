sound = pd.sound
game_synth = sound.synth.new(sound.kWavePOVosim)

function mine_sound()
    game_synth:playNote("Db3",1,0.25)
end