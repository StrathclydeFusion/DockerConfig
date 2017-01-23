#!/usr/bin/env liquidsoap


%include "utils.liq"


# CONFIGS
set("log.file", true)
set("log.stdout", true)
set("log.level", 4)
set("server.telnet", true)
set("server.telnet.port", 5000)
set("log.file.path", "/tmp/broadcast.log")
set("audio.converter.samplerate.libsamplerate.quality","best")
set("buffering.path","/tmp")
set("decoding.buffer_length",10.)


# FUNCTIONS
scc_out = output.icecast(description="University of Strathclyde Student Radio", genre="Documentaires", url="http://www.strathclydefusion.com/")
output_docker_env.icecast = scc_out(
    host="icecast",
    port=8000,
    password=my_getenv("ICECAST_SOURCE_PASSWORD")
)
#output_balrog.icecast = scc_out(host="212.83.158.125", port=8000, password=icecast_password)
#output_hobbit.icecast = scc_out(host="212.129.20.90", port=8000, password=icecast_password)
def outputs(encoder, ~mount, input)
    #output_balrog.icecast(encoder, mount=mount, input)
    #output_hobbit.icecast(encoder, mount=mount, input)
    output_docker_env.icecast(encoder, mount=mount, input)
end


# MIXS
default = mksafe(
    rewrite_metadata(
        [
            ("artist", "Strathclyde Fusion"),
            ("title", "Something Went Wrong :("),
            ("comment", "http://www.strathcestcool.com/")
            ],
        audio_to_stereo(
            playlist.safe(
                reload=60,
                "/playlists/failures/",
                mode="random"
                )
            )
        )
    )

harbor_input = input.harbor("strath.main", port=5001, password=my_getenv("HARBOR_PASSWORD"))
input = mksafe(fallback(track_sensitive=false, [ harbor_input, default ]))


# NORMALIZE
#input = audio_process(input)


# OUTPUTS
outputs(%mp3(bitrate=64), mount="/strath-radio-64.mp3", input)
outputs(%mp3(bitrate=128), mount="/strath-radio-128.mp3", input)
outputs(%mp3(bitrate=160), mount="/strath-radio-160.mp3", input)
outputs(%mp3(bitrate=192), mount="/strath-radio-192.mp3", input)
outputs(%aac(bitrate=128), mount="/strath-radio-128.aac", input)
outputs(%aac(bitrate=160), mount="/strath-radio-160.aac", input)
outputs(%aac(bitrate=192), mount="/strath-radio-192.aac", input)
outputs(%vorbis, mount="/strath-radio.ogg", input)
