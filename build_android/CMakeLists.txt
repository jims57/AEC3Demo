cmake_minimum_required(VERSION 3.18)
project(webrtc_aec3_real)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add compile definitions for WebRTC
add_definitions(
    -DWEBRTC_POSIX
    -DWEBRTC_ANDROID
    -DWEBRTC_LINUX
    -DABSL_ALLOCATOR_NOTHROW=1
    -DHAVE_PTHREAD
    -DWEBRTC_THREAD_RR
    -DWEBRTC_CLOCK_TYPE_REALTIME
)

# Compiler flags for optimized mobile build
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -ffast-math -DNDEBUG")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti -fno-exceptions")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wno-unused-parameter")

# Include directories - Real WebRTC AEC3 structure
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/..)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../absl)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../api)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../common_audio)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../modules)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../rtc_base)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../system_wrappers/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../third_party/pffft/src)

# Essential WebRTC AEC3 files for TTS echo cancellation - 2025-01-28
set(WEBRTC_AEC3_SOURCES
    # API files - Required for AEC3 factory and configuration
    "../api/audio/echo_canceller3_factory.cc"
    "../api/audio/echo_canceller3_config.cc"
    "../api/audio/audio_frame.cc"
    
    # Core AEC3 echo cancellation modules - Available in AEC3Demo
    "../modules/audio_processing/aec3/echo_canceller3.cc"
    "../modules/audio_processing/aec3/echo_remover.cc"
    "../modules/audio_processing/aec3/subtractor.cc"
    "../modules/audio_processing/aec3/suppression_filter.cc"
    "../modules/audio_processing/aec3/render_buffer.cc"
    "../modules/audio_processing/aec3/render_delay_controller.cc"
    "../modules/audio_processing/aec3/render_delay_buffer.cc"
    "../modules/audio_processing/aec3/render_signal_analyzer.cc"
    "../modules/audio_processing/aec3/echo_path_variability.cc"
    "../modules/audio_processing/aec3/erl_estimator.cc"
    "../modules/audio_processing/aec3/erle_estimator.cc"
    "../modules/audio_processing/aec3/fullband_erle_estimator.cc"
    "../modules/audio_processing/aec3/subband_erle_estimator.cc"
    "../modules/audio_processing/aec3/signal_dependent_erle_estimator.cc"
    "../modules/audio_processing/aec3/residual_echo_estimator.cc"
    "../modules/audio_processing/aec3/reverb_model_estimator.cc"
    "../modules/audio_processing/aec3/reverb_decay_estimator.cc"
    "../modules/audio_processing/aec3/reverb_frequency_response.cc"
    "../modules/audio_processing/aec3/reverb_model.cc"
    "../modules/audio_processing/aec3/subband_nearend_detector.cc"
    "../modules/audio_processing/aec3/stationarity_estimator.cc"
    "../modules/audio_processing/aec3/spectrum_buffer.cc"
    "../modules/audio_processing/aec3/fft_buffer.cc"
    "../modules/audio_processing/aec3/filter_analyzer.cc"
    "../modules/audio_processing/aec3/frame_blocker.cc"
    "../modules/audio_processing/aec3/moving_average.cc"
    "../modules/audio_processing/aec3/matched_filter.cc"
    "../modules/audio_processing/aec3/matched_filter_lag_aggregator.cc"
    "../modules/audio_processing/aec3/refined_filter_update_gain.cc"
    "../modules/audio_processing/aec3/subtractor_output.cc"
    "../modules/audio_processing/aec3/subtractor_output_analyzer.cc"
    "../modules/audio_processing/aec3/suppression_gain.cc"
    "../modules/audio_processing/aec3/echo_remover_metrics.cc"
    "../modules/audio_processing/aec3/render_delay_controller_metrics.cc"
    
    # Required AEC3 support modules
    "../modules/audio_processing/aec3/multi_channel_content_detector.cc"
    
    # Audio processing support files
    "../modules/audio_processing/audio_buffer.cc"
    "../modules/audio_processing/high_pass_filter.cc"
    "../modules/audio_processing/splitting_filter.cc"
    "../modules/audio_processing/three_band_filter_bank.cc"
    
    # Essential audio processing
    "../modules/audio_processing/audio_buffer.cc"
    "../modules/audio_processing/high_pass_filter.cc"
    "../modules/audio_processing/splitting_filter.cc"
    "../modules/audio_processing/three_band_filter_bank.cc"
    
    # API layer for AEC3
    "../api/audio/echo_canceller3_config.cc"
    "../api/audio/echo_canceller3_factory.cc"
    
    # Essential common audio
    "../common_audio/channel_buffer.cc"
    "../common_audio/real_fourier.cc"
    "../common_audio/real_fourier_ooura.cc"
    "../common_audio/audio_util.cc"
    "../common_audio/signal_processing/complex_fft.c"
    "../common_audio/signal_processing/real_fft.c"
    "../common_audio/signal_processing/spl_init.c"
    "../common_audio/third_party/ooura/fft_size_128/ooura_fft.cc"
    
    # Minimal rtc_base
    "../rtc_base/checks.cc"
    "../rtc_base/memory/aligned_malloc.cc"
)

# Filter out any remaining platform-specific files
list(FILTER WEBRTC_AEC3_SOURCES EXCLUDE REGEX ".*avx2\\.cc$")
list(FILTER WEBRTC_AEC3_SOURCES EXCLUDE REGEX ".*sse\\.cc$")
list(FILTER WEBRTC_AEC3_SOURCES EXCLUDE REGEX ".*mips\\.c$")
list(FILTER WEBRTC_AEC3_SOURCES EXCLUDE REGEX ".*neon\\.cc$")
list(FILTER WEBRTC_AEC3_SOURCES EXCLUDE REGEX ".*unittest\\.cc$")
list(FILTER WEBRTC_AEC3_SOURCES EXCLUDE REGEX ".*test\\.cc$")

# Note: Explicitly exclude platform-specific optimizations that cause build issues
# - No SSE/AVX/AVX2 files (x86 only)
# - No MIPS-specific files  
# - No NEON files that don't match function signatures
# - No test/benchmark files

# Add JNI wrapper source
set(JNI_WRAPPER_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/webrtc_aec3_real_jni.cpp")

# Create the shared library
add_library(webrtc_aec3_real SHARED
    ${WEBRTC_AEC3_SOURCES}
    ${JNI_WRAPPER_SOURCE}
)

# Link system libraries
target_link_libraries(webrtc_aec3_real
    log
    m
    android
)

# Set library properties
set_target_properties(webrtc_aec3_real PROPERTIES
    ANDROID_ARM_MODE arm
)
