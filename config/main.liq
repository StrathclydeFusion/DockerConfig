#!/usr/bin/env liquidsoap


%include "utils.liq"


# CONFIGS
set("log.file", true)
set("log.stdout", true)
set("log.level", 5)
set("server.telnet", true)
set("server.telnet.port", 5000)
set("server.telnet.bind_addr", "0.0.0.0")
set("log.file.path", "/tmp/broadcast.log")
set("audio.converter.samplerate.libsamplerate.quality","best")
set("buffering.path","/tmp")
set("decoding.buffer_length",10.)

live_scc = audio_to_stereo(
    rewrite_metadata(
        [
            ("title", "$(title) (LIVE from the studio - Radio Strathclyde Fusion)"),
            ("comment", "http://www.salutcestcool.com")
            ],
        stretch(
            ratio=interactive.float("test", 1.00005),
            input.harbor(
                "strath.live",
                id="strath.live",
                port=5002,
                password=my_getenv("LIVE_PASSWORD"),
                user="source",
                logfile="/tmp/harbor.log"
                )
            )
        )
    )
live_guest = audio_to_stereo(
    rewrite_metadata(
        [
            ("title", "$(title) (LIVE from the ouside - Radio Strathclyde Fusion)"),
            ("comment", "http://www.salutcestcool.com")
            ],
        stretch(
            ratio=interactive.float("test", 1.00005),
            input.harbor(
                "strath.live",
                id="strath.live",
                port=5001,
                password=my_getenv("LIVE_PASSWORD"),
                user="source",
                logfile="/tmp/harbor.log"
                )
            )
        )
    )
#live = strip_blank(live, length=10., threshold=-50.)

default = mksafe(
    rewrite_metadata(
        [
            ("artist", "Strathclyde Fusion"),
            ("title", "Something Went Wrong :( M1"),
            ("comment", "http://www.strathcestcool.com/")
            ],
        audio_to_stereo(
            playlist.safe(
                reload=60,
                "/playlists/main/",
                mode="random"
                )
            )
        )
    )

mix = fallback(track_sensitive=false, [live_scc, live_guest, default])
mix = store_metadata(size=20,id="history",mix)
def feedback(metadata)
   system("echo "^ quote(metadata["artist"] ^" - "^ metadata["title"]) ^" > /data/latest.txt")
   system("echo "^ quote(metadata["artist"] ^" - "^ metadata["title"]) ^" >> /data/history.txt")
end
mix = on_metadata(feedback, mix)


# OUTPUTS
input = mksafe(mix)
#output.icecast(
#    password=my_getenv("HARBOR_PASSWORD"),
#    host="broadcast",
#    port=5001,
#    %wav,
#    mount="strath.main",
#    mix
#    )

# FUNCTIONS
scc_out = output.icecast(description="University of Strathclyde Student Radio", genre="Student Radio", url="http://www.strathclydefusion.com/")
output_docker_env.icecast = scc_out(
    host="icecast",
    port=8000,
    password=my_getenv("ICECAST_SOURCE_PASSWORD")
)

def outputs(encoder, ~mount, input)
    output_docker_env.icecast(encoder, mount=mount, input)
end


# OUTPUTS
outputs(%mp3(bitrate=64), mount="/strath-radio-64.mp3", input)
outputs(%mp3(bitrate=128), mount="/strath-radio-128.mp3", input)
outputs(%mp3(bitrate=160), mount="/strath-radio-160.mp3", input)
outputs(%mp3(bitrate=192), mount="/strath-radio-192.mp3", input)
#outputs(%aac(bitrate=128), mount="/strath-radio-128.aac", input)
#outputs(%aac(bitrate=160), mount="/strath-radio-160.aac", input)
#outputs(%aac(bitrate=192), mount="/strath-radio-192.aac", input)
outputs(%vorbis, mount="/strath-radio.ogg", input)

#title = '%Y-%m-%d, %H:%M:%S - $(if $(artist), "$(artist)", "Artiste inconnu") - $(if $(title),"$(title)", "Emission inconnue")'
#output.file(
#    %vorbis,
#     reopen_on_metadata=false,
#     fallible=true,
#     "/playlists/emissions/scc/" ^ title ^ ".ogg",
#     live_scc
#     )
#output.file(
#    %vorbis,
#     reopen_on_metadata=false,
#     fallible=true,
#     "/playlists/emissions/guest/" ^ title ^ ".ogg",
#     live_guest
#)
