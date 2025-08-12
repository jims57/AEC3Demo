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

# Use a minimal, working subset of WebRTC AEC3 sources - Android compatible
file(GLOB WEBRTC_AEC3_SOURCES
    # Core AEC3 modules (exclude platform-specific files)
    "../modules/audio_processing/aec3/echo_canceller3.cc"
    "../modules/audio_processing/aec3/aec3_common.cc"
    "../modules/audio_processing/aec3/aec3_fft.cc"
    "../modules/audio_processing/aec3/aec_state.cc"
    "../modules/audio_processing/aec3/adaptive_fir_filter.cc"
    "../modules/audio_processing/aec3/adaptive_fir_filter_erl.cc"
    "../modules/audio_processing/aec3/alignment_mixer.cc"
    "../modules/audio_processing/aec3/api_call_jitter_metrics.cc"
    "../modules/audio_processing/aec3/block_buffer.cc"
    "../modules/audio_processing/aec3/block_delay_buffer.cc"
    "../modules/audio_processing/aec3/block_framer.cc"
    "../modules/audio_processing/aec3/block_processor.cc"
    "../modules/audio_processing/aec3/block_processor_metrics.cc"
    "../modules/audio_processing/aec3/clockdrift_detector.cc"
    "../modules/audio_processing/aec3/coarse_filter_update_gain.cc"
    "../modules/audio_processing/aec3/comfort_noise_generator.cc"
    "../modules/audio_processing/aec3/config_selector.cc"
    "../modules/audio_processing/aec3/decimator.cc"
    "../modules/audio_processing/aec3/dominant_nearend_detector.cc"
    "../modules/audio_processing/aec3/downsampled_render_buffer.cc"
    "../modules/audio_processing/aec3/echo_audibility.cc"
    "../modules/audio_processing/aec3/echo_path_delay_estimator.cc"
    "../modules/audio_processing/aec3/echo_path_variability.cc"
    "../modules/audio_processing/aec3/echo_remover.cc"
    "../modules/audio_processing/aec3/echo_remover_metrics.cc"
    "../modules/audio_processing/aec3/erl_estimator.cc"
    "../modules/audio_processing/aec3/erle_estimator.cc"
    "../modules/audio_processing/aec3/fft_buffer.cc"
    "../modules/audio_processing/aec3/filter_analyzer.cc"
    "../modules/audio_processing/aec3/frame_blocker.cc"
    "../modules/audio_processing/aec3/fullband_erle_estimator.cc"
    "../modules/audio_processing/aec3/matched_filter.cc"
    "../modules/audio_processing/aec3/matched_filter_lag_aggregator.cc"
    "../modules/audio_processing/aec3/moving_average.cc"
    "../modules/audio_processing/aec3/multi_channel_content_detector.cc"
    "../modules/audio_processing/aec3/refined_filter_update_gain.cc"
    "../modules/audio_processing/aec3/render_buffer.cc"
    "../modules/audio_processing/aec3/render_delay_buffer.cc"
    "../modules/audio_processing/aec3/render_delay_controller.cc"
    "../modules/audio_processing/aec3/render_delay_controller_metrics.cc"
    "../modules/audio_processing/aec3/render_signal_analyzer.cc"
    "../modules/audio_processing/aec3/residual_echo_estimator.cc"
    "../modules/audio_processing/aec3/reverb_decay_estimator.cc"
    "../modules/audio_processing/aec3/reverb_frequency_response.cc"
    "../modules/audio_processing/aec3/reverb_model.cc"
    "../modules/audio_processing/aec3/reverb_model_estimator.cc"
    "../modules/audio_processing/aec3/signal_dependent_erle_estimator.cc"
    "../modules/audio_processing/aec3/spectrum_buffer.cc"
    "../modules/audio_processing/aec3/stationarity_estimator.cc"
    "../modules/audio_processing/aec3/subband_erle_estimator.cc"
    "../modules/audio_processing/aec3/subband_nearend_detector.cc"
    "../modules/audio_processing/aec3/subtractor.cc"
    "../modules/audio_processing/aec3/subtractor_output.cc"
    "../modules/audio_processing/aec3/subtractor_output_analyzer.cc"
    "../modules/audio_processing/aec3/suppression_filter.cc"
    "../modules/audio_processing/aec3/suppression_gain.cc"
    "../modules/audio_processing/aec3/transparent_mode.cc"
    
    # Audio processing core
    "../modules/audio_processing/audio_buffer.cc"
    "../modules/audio_processing/high_pass_filter.cc"
    "../modules/audio_processing/splitting_filter.cc"
    "../modules/audio_processing/three_band_filter_bank.cc"
    "../modules/audio_processing/rms_level.cc"
    "../modules/audio_processing/utility/cascaded_biquad_filter.cc"
    "../modules/audio_processing/utility/delay_estimator.cc"
    "../modules/audio_processing/utility/delay_estimator_wrapper.cc"
    "../modules/audio_processing/utility/pffft_wrapper.cc"
    
    # API layer (exclude problematic echo detector)
    "../api/audio/audio_frame.cc"
    "../api/audio/channel_layout.cc"
    "../api/audio/echo_canceller3_config.cc"
    "../api/audio/echo_canceller3_factory.cc"
    # "../api/audio/echo_detector_creator.cc"  # Missing ResidualEchoDetector implementation
    
    # Essential dependencies only
    "../common_audio/channel_buffer.cc"
    "../common_audio/real_fourier.cc"
    "../common_audio/real_fourier_ooura.cc"
    "../common_audio/fir_filter_c.cc"
    "../common_audio/fir_filter_factory.cc"
    "../common_audio/audio_util.cc"
    "../common_audio/resampler/sinc_resampler.cc"
    "../common_audio/resampler/push_resampler.cc"
    "../common_audio/resampler/push_sinc_resampler.cc"
    "../common_audio/signal_processing/energy.c"
    "../common_audio/signal_processing/auto_correlation.c"
    "../common_audio/signal_processing/levinson_durbin.c"
    "../common_audio/signal_processing/filter_ma_fast_q12.c"
    "../common_audio/signal_processing/complex_fft.c"
    "../common_audio/signal_processing/real_fft.c"
    "../common_audio/signal_processing/spl_sqrt.c"
    "../common_audio/signal_processing/spl_init.c"
    "../common_audio/signal_processing/downsample_fast.c"
    "../common_audio/signal_processing/resample_by_2_internal.c"
    "../common_audio/signal_processing/get_scaling_square.c"
    "../common_audio/signal_processing/division_operations.c"
    "../common_audio/signal_processing/complex_bit_reverse.c"
    "../common_audio/signal_processing/min_max_operations.c"
    
    # Essential rtc_base
    "../rtc_base/checks.cc"
    "../rtc_base/logging.cc"
    "../rtc_base/string_utils.cc"
    "../rtc_base/strings/string_builder.cc"
    "../rtc_base/time_utils.cc"
    "../rtc_base/memory/aligned_malloc.cc"
    
    # System wrappers
    "../system_wrappers/source/cpu_features.cc"
    "../system_wrappers/source/field_trial.cc"
    
    # Skip pffft - has Windows dependency issues
    # "../third_party/pffft/src/pffft.c"
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
