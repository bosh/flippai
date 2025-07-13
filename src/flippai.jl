using VideoIO: VideoIO, AVInput, VideoReader

abstract type VideoSource end

get_next_frame(vs::VideoSource) = error("No get_next_frame method defined for VideoSource type $(typeof(vs))")

mutable struct FakeVideoSource <: VideoSource
  testvideo::AVInput
  video_stream::VideoReader
  frames_read::Int
end

function FakeVideoSource()
  testvideo = VideoIO.testvideo("annie_oakley")
  video_stream = VideoIO.openvideo(testvideo)
  frames_read = 0
  return FakeVideoSource(testvideo, video_stream, frames_read)
end

function get_next_frame(fvs::FakeVideoSource)::Any
  img = read(fvs.video_stream)
  if !eof(fvs.video_stream)
    read!(fvs.video_stream, img)
    fvs.frames_read += 1
    return img
  else
    close(fvs.video_stream)
    return nothing
  end
end

struct CameraVideoSource <: VideoSource
  cam::VideoReader
  frames_read::Int
end

# framerate ex: "24"
# resolution ex: "800x600"
function CameraVideoSource(framerate::String, resolution::String)
  opts = VideoIO.DEFAULT_CAMERA_OPTIONS
  opts["framerate"] = framerate
  opts["video_size"] = resolution
  cam = VideoIO.opencamera(VideoIO.DEFAULT_CAMERA_DEVICE[], VideoIO.DEFAULT_CAMERA_FORMAT[], opts)
  frames_read = 0
  return CameraVideoSource(cam, frames_read)
end

function get_next_frame(cvs::CameraVideoSource)
  image = read(cvs.cam)
  if !eof(image)
    frames_read += 1
  end
  return image
end

function main(video_source::VideoSource)
  println("Hello world!")
  get_next_frame(video_source)
  println(video_source.frames_read)
end

main(FakeVideoSource())
