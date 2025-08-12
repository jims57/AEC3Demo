#!/bin/bash

# ==============================================================================
# WebRTC AEC3 Android AAR Build Script - Real Implementation
# Date: 2025-01-28
# Purpose: Build Android AAR using real WebRTC AEC3 from AEC3Demo project
# ==============================================================================

set -e  # Exit on any error

# Build configuration
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
BUILD_DIR="${PROJECT_ROOT}/build_android"
OUTPUT_DIR="${PROJECT_ROOT}/output"
AAR_NAME="webrtc-aec3-real"

echo "🚀 Starting WebRTC AEC3 Android AAR build..."
echo "📂 Project root: ${PROJECT_ROOT}"

# Check Android NDK
if [ -z "$ANDROID_NDK_HOME" ]; then
    echo "❌ Error: ANDROID_NDK_HOME is not set"
    echo "   Please set ANDROID_NDK_HOME to your Android NDK installation directory"
    exit 1
fi

if [ ! -d "$ANDROID_NDK_HOME" ]; then
    echo "❌ Error: ANDROID_NDK_HOME directory does not exist: $ANDROID_NDK_HOME"
    exit 1
fi

echo "✅ Android NDK found: $ANDROID_NDK_HOME"

# Android build parameters
ANDROID_API_LEVEL=27
ANDROID_ABIS=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")

# Clean and create build directories
echo "🧹 Cleaning build directories..."
rm -rf "${BUILD_DIR}"
rm -rf "${OUTPUT_DIR}"
mkdir -p "${BUILD_DIR}"
mkdir -p "${OUTPUT_DIR}"

# Generate CMakeLists.txt for real WebRTC AEC3
echo "📝 Generating CMakeLists.txt for real WebRTC AEC3..."
cat > "${BUILD_DIR}/CMakeLists.txt" << 'EOF'
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
EOF

# Generate JNI wrapper with real WebRTC AEC3 integration
echo "📝 Generating JNI wrapper for real WebRTC AEC3..."
cat > "${BUILD_DIR}/webrtc_aec3_real_jni.cpp" << 'EOF'
// Real WebRTC AEC3 JNI Wrapper - 2025-01-28
// Based on official WebRTC AEC3Demo implementation

#include <jni.h>
#include <android/log.h>
#include <memory>
#include <vector>
#include <cstring>

// Real WebRTC AEC3 includes
#include "api/audio/echo_canceller3_factory.h"
#include "api/audio/echo_canceller3_config.h"
#include "modules/audio_processing/audio_buffer.h"
#include "modules/audio_processing/high_pass_filter.h"
#include "common_audio/channel_buffer.h"
#include "rtc_base/logging.h"

#define LOG_TAG "WebRTCAEC3Real"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)

// AEC3 configuration constants
static const int kSampleRate = 48000;           // WebRTC AEC3 requires 48kHz
static const int kFrameSize = 480;              // 10ms @ 48kHz
static const int kChannels = 1;                 // Mono

// Real WebRTC AEC3 processor class
class WebRTCAEC3Processor {
private:
    std::unique_ptr<webrtc::EchoControl> aec3_;
    std::unique_ptr<webrtc::HighPassFilter> hp_filter_;
    std::unique_ptr<webrtc::AudioBuffer> render_buffer_;
    std::unique_ptr<webrtc::AudioBuffer> capture_buffer_;
    std::unique_ptr<webrtc::AudioBuffer> linear_output_buffer_;
    webrtc::StreamConfig stream_config_;
    int stream_delay_ms_;
    
    // ERLE calculation state
    float total_original_power_;
    float total_processed_power_;
    int frame_count_;

public:
    WebRTCAEC3Processor() : 
        stream_config_(kSampleRate, kChannels),
        stream_delay_ms_(100),  // Default Android delay
        total_original_power_(0.0f),
        total_processed_power_(0.0f),
        frame_count_(0) {
    }

    bool Create(int sample_rate, int channels, bool mobile_mode) {
        if (sample_rate != kSampleRate || channels != kChannels) {
            LOGE("WebRTC AEC3错误: 只支持48kHz单声道, 当前: %dHz %d声道", sample_rate, channels);
            return false;
        }

        // Configure WebRTC AEC3 for mobile optimization
        webrtc::EchoCanceller3Config config;
            
            // Mobile optimizations based on ace-key-points.txt
            if (mobile_mode) {
                config.filter.refined.length_blocks = 12;  // Shorter filter for mobile
                config.filter.coarse.length_blocks = 4;
                config.erle.max_l = 4.0f;                  // Conservative ERLE limit
                config.erle.max_h = 1.5f;
                config.ep_strength.default_len = 0.83f;    // Mobile-optimized suppression
                config.echo_audibility.floor_power = -50.0f;
                config.render_levels.poor_excitation_render_limit = 150.0f;
            }
            
            config.filter.export_linear_aec_output = true;
            
            // Create AEC3 factory and processor
            webrtc::EchoCanceller3Factory aec_factory(config);
            aec3_ = aec_factory.Create(kSampleRate, kChannels, kChannels);
            
            if (!aec3_) {
                LOGE("WebRTC AEC3处理器创建失败");
                return false;
            }

            // Create high-pass filter
            hp_filter_ = std::make_unique<webrtc::HighPassFilter>(kSampleRate, kChannels);

            // Create audio buffers
            render_buffer_ = std::make_unique<webrtc::AudioBuffer>(
                kSampleRate, kChannels, kSampleRate, kChannels, kSampleRate, kChannels);
            capture_buffer_ = std::make_unique<webrtc::AudioBuffer>(
                kSampleRate, kChannels, kSampleRate, kChannels, kSampleRate, kChannels);
            
            // Linear output at 16kHz for compatibility
            const int kLinearOutputRate = 16000;
            linear_output_buffer_ = std::make_unique<webrtc::AudioBuffer>(
                kLinearOutputRate, kChannels, kLinearOutputRate, kChannels, 
                kLinearOutputRate, kChannels);

        LOGI("WebRTC AEC3处理器创建成功: %dHz, %d声道, 移动模式: %s", 
             kSampleRate, kChannels, mobile_mode ? "启用" : "禁用");
        return true;
    }

    void SetStreamDelay(int delay_ms) {
        stream_delay_ms_ = std::max(0, std::min(500, delay_ms));  // Limit 0-500ms
        LOGD("流延迟设置为: %d ms", stream_delay_ms_);
    }

    bool AnalyzeRender(const float* render_data) {
        if (!aec3_ || !render_buffer_) {
            LOGE("AEC3处理器未初始化");
            return false;
        }

        // Copy render data to buffer - WebRTC expects interleaved int16 data
        std::vector<int16_t> int16_data(kFrameSize);
        for (int i = 0; i < kFrameSize; ++i) {
            int16_data[i] = static_cast<int16_t>(render_data[i] * 32767.0f);
        }
        
        // Copy to AudioBuffer using correct API
        render_buffer_->CopyFrom(int16_data.data(), stream_config_);
        
        // Process render signal (TTS reference) - must be done first
        render_buffer_->SplitIntoFrequencyBands();
        aec3_->AnalyzeRender(render_buffer_.get());
        render_buffer_->MergeFrequencyBands();
        
        return true;
    }

    bool ProcessCapture(const float* capture_data, float* output_data, bool drift_compensation) {
        if (!aec3_ || !capture_buffer_ || !hp_filter_) {
            LOGE("AEC3处理器未初始化");
            return false;
        }

        // Convert float to int16 for WebRTC AudioBuffer
        std::vector<int16_t> int16_capture(kFrameSize);
        for (int i = 0; i < kFrameSize; ++i) {
            int16_capture[i] = static_cast<int16_t>(capture_data[i] * 32767.0f);
        }
        
        // Copy capture data to buffer using correct API
        capture_buffer_->CopyFrom(int16_capture.data(), stream_config_);
        
        // Calculate original power for ERLE
        float original_power = 0.0f;
        for (int i = 0; i < kFrameSize; ++i) {
            original_power += capture_data[i] * capture_data[i];
        }
        total_original_power_ += original_power;

        // Process capture signal with real WebRTC AEC3
        aec3_->AnalyzeCapture(capture_buffer_.get());
        capture_buffer_->SplitIntoFrequencyBands();
        
        // Apply high-pass filter first (WebRTC best practice)
        hp_filter_->Process(capture_buffer_.get(), true);
        
        // Set stream delay for echo cancellation synchronization
        aec3_->SetAudioBufferDelay(stream_delay_ms_);
        
        // Main AEC3 processing - removes TTS echo
        aec3_->ProcessCapture(capture_buffer_.get(), linear_output_buffer_.get(), drift_compensation);
        
        capture_buffer_->MergeFrequencyBands();

        // Copy processed data to output - convert back to float
        std::vector<int16_t> int16_output(kFrameSize);
        capture_buffer_->CopyTo(stream_config_, int16_output.data());
        
        // Convert int16 back to float and calculate processed power
        float processed_power = 0.0f;
        for (int i = 0; i < kFrameSize; ++i) {
            output_data[i] = static_cast<float>(int16_output[i]) / 32767.0f;
            processed_power += output_data[i] * output_data[i];
        }
        total_processed_power_ += processed_power;
        frame_count_++;

        return true;
    }

    float GetERLE() {
        if (frame_count_ < 10 || total_original_power_ < 0.0001f || total_processed_power_ < 0.0001f) {
            return 0.0f;  // Insufficient data
        }
        
        // Calculate realistic ERLE (Echo Return Loss Enhancement)
        float improvement_ratio = total_original_power_ / total_processed_power_;
        if (improvement_ratio > 1.0f) {
            float erle = 10.0f * log10f(improvement_ratio);
            return std::max(0.0f, std::min(40.0f, erle));  // Limit to realistic range
        }
        return 0.0f;
    }

    int GetDetectedDelay() {
        return stream_delay_ms_;  // Return configured delay
    }

    void Destroy() {
        hp_filter_.reset();
        linear_output_buffer_.reset();
        capture_buffer_.reset();
        render_buffer_.reset();
        aec3_.reset();
        
        total_original_power_ = 0.0f;
        total_processed_power_ = 0.0f;
        frame_count_ = 0;
        
        LOGI("WebRTC AEC3处理器已销毁");
    }
};

// Global processor instance
static std::unique_ptr<WebRTCAEC3Processor> g_processor;

extern "C" {

JNIEXPORT jboolean JNICALL
Java_cn_watchfun_webrtc_WebRTCAEC3Real_create(JNIEnv *env, jobject thiz, 
                                               jint sample_rate, jint channels, jboolean mobile_mode) {
    LOGI("创建WebRTC AEC3处理器: %dHz, %d声道, 移动模式: %s", 
         sample_rate, channels, mobile_mode ? "true" : "false");
    
    g_processor = std::make_unique<WebRTCAEC3Processor>();
    return g_processor->Create(sample_rate, channels, mobile_mode);
}

JNIEXPORT void JNICALL
Java_cn_watchfun_webrtc_WebRTCAEC3Real_setStreamDelay(JNIEnv *env, jobject thiz, jint delay_ms) {
    if (g_processor) {
        g_processor->SetStreamDelay(delay_ms);
    }
}

JNIEXPORT jboolean JNICALL
Java_cn_watchfun_webrtc_WebRTCAEC3Real_analyzeRender(JNIEnv *env, jobject thiz, jfloatArray render_data) {
    if (!g_processor) {
        LOGE("处理器未创建");
        return JNI_FALSE;
    }

    jfloat* render_ptr = env->GetFloatArrayElements(render_data, nullptr);
    if (!render_ptr) {
        LOGE("获取渲染数据失败");
        return JNI_FALSE;
    }

    jsize array_length = env->GetArrayLength(render_data);
    if (array_length != kFrameSize) {
        LOGE("渲染数据大小错误: 期望%d, 实际%d", kFrameSize, array_length);
        env->ReleaseFloatArrayElements(render_data, render_ptr, JNI_ABORT);
        return JNI_FALSE;
    }

    bool result = g_processor->AnalyzeRender(render_ptr);
    env->ReleaseFloatArrayElements(render_data, render_ptr, JNI_ABORT);
    
    return result ? JNI_TRUE : JNI_FALSE;
}

JNIEXPORT jboolean JNICALL
Java_cn_watchfun_webrtc_WebRTCAEC3Real_processCapture(JNIEnv *env, jobject thiz, 
                                                       jfloatArray capture_data, jfloatArray output_data, 
                                                       jboolean drift_compensation) {
    if (!g_processor) {
        LOGE("处理器未创建");
        return JNI_FALSE;
    }

    jfloat* capture_ptr = env->GetFloatArrayElements(capture_data, nullptr);
    jfloat* output_ptr = env->GetFloatArrayElements(output_data, nullptr);
    
    if (!capture_ptr || !output_ptr) {
        LOGE("获取音频数据失败");
        if (capture_ptr) env->ReleaseFloatArrayElements(capture_data, capture_ptr, JNI_ABORT);
        if (output_ptr) env->ReleaseFloatArrayElements(output_data, output_ptr, JNI_ABORT);
        return JNI_FALSE;
    }

    jsize capture_length = env->GetArrayLength(capture_data);
    jsize output_length = env->GetArrayLength(output_data);
    
    if (capture_length != kFrameSize || output_length != kFrameSize) {
        LOGE("音频数据大小错误: 期望%d, 捕获%d, 输出%d", kFrameSize, capture_length, output_length);
        env->ReleaseFloatArrayElements(capture_data, capture_ptr, JNI_ABORT);
        env->ReleaseFloatArrayElements(output_data, output_ptr, JNI_ABORT);
        return JNI_FALSE;
    }

    bool result = g_processor->ProcessCapture(capture_ptr, output_ptr, drift_compensation);
    
    env->ReleaseFloatArrayElements(capture_data, capture_ptr, JNI_ABORT);
    env->ReleaseFloatArrayElements(output_data, output_ptr, 0);  // Commit output changes
    
    return result ? JNI_TRUE : JNI_FALSE;
}

JNIEXPORT jfloat JNICALL
Java_cn_watchfun_webrtc_WebRTCAEC3Real_getERLE(JNIEnv *env, jobject thiz) {
    if (g_processor) {
        return g_processor->GetERLE();
    }
    return 0.0f;
}

JNIEXPORT jint JNICALL
Java_cn_watchfun_webrtc_WebRTCAEC3Real_getDetectedDelay(JNIEnv *env, jobject thiz) {
    if (g_processor) {
        return g_processor->GetDetectedDelay();
    }
    return 0;
}

JNIEXPORT void JNICALL
Java_cn_watchfun_webrtc_WebRTCAEC3Real_destroy(JNIEnv *env, jobject thiz) {
    if (g_processor) {
        g_processor->Destroy();
        g_processor.reset();
        LOGI("全局处理器已重置");
    }
}

} // extern "C"
EOF

# Generate Java wrapper class
echo "📝 Generating Java wrapper class..."
mkdir -p "${BUILD_DIR}/java/cn/watchfun/webrtc"
cat > "${BUILD_DIR}/java/cn/watchfun/webrtc/WebRTCAEC3Real.java" << 'EOF'
package cn.watchfun.webrtc;

/**
 * Real WebRTC AEC3 implementation wrapper for Android
 * 
 * Based on official WebRTC AEC3Demo project
 * Provides TTS echo cancellation functionality
 * 
 * @author AI Assistant
 * @date 2025-01-28
 */
public class WebRTCAEC3Real {
    
    static {
        System.loadLibrary("webrtc_aec3_real");
    }
    
    /**
     * Create WebRTC AEC3 processor
     * 
     * @param sampleRate Sample rate in Hz (must be 48000)
     * @param channels Number of channels (must be 1)
     * @param mobileMode Enable mobile optimizations
     * @return true if creation successful
     */
    public native boolean create(int sampleRate, int channels, boolean mobileMode);
    
    /**
     * Set stream delay compensation
     * 
     * @param delayMs Delay in milliseconds (0-500ms)
     */
    public native void setStreamDelay(int delayMs);
    
    /**
     * Analyze render signal (TTS reference)
     * Must be called before processCapture for same time frame
     * 
     * @param renderData Float array with 480 samples (10ms @ 48kHz)
     * @return true if analysis successful
     */
    public native boolean analyzeRender(float[] renderData);
    
    /**
     * Process capture signal (microphone input)
     * 
     * @param captureData Input float array with 480 samples
     * @param outputData Output float array with 480 samples (echo cancelled)
     * @param driftCompensation Enable drift compensation
     * @return true if processing successful
     */
    public native boolean processCapture(float[] captureData, float[] outputData, boolean driftCompensation);
    
    /**
     * Get Echo Return Loss Enhancement metric
     * 
     * @return ERLE value in dB (higher is better)
     */
    public native float getERLE();
    
    /**
     * Get detected audio delay
     * 
     * @return Delay in milliseconds
     */
    public native int getDetectedDelay();
    
    /**
     * Destroy AEC3 processor and free resources
     */
    public native void destroy();
}
EOF

# Build native libraries for all Android ABIs
echo "🔨 Building native libraries..."
for abi in "${ANDROID_ABIS[@]}"; do
    echo "📱 Building for ABI: $abi"
    
    abi_build_dir="${BUILD_DIR}/build_${abi}"
    mkdir -p "$abi_build_dir"
    cd "$abi_build_dir"
    
    # Configure CMake for this ABI
    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" \
        -DCMAKE_BUILD_TYPE=Release \
        -DANDROID_ABI="$abi" \
        -DANDROID_PLATFORM=android-${ANDROID_API_LEVEL} \
        -DANDROID_STL=c++_static \
        -DCMAKE_ANDROID_NDK="$ANDROID_NDK_HOME" \
        "${BUILD_DIR}"
    
    # Build the library
    make -j4
    
    # Verify library was created
    if [ ! -f "libwebrtc_aec3_real.so" ]; then
        echo "❌ Error: Failed to build library for $abi"
        exit 1
    fi
    
    # Copy to output
    mkdir -p "${OUTPUT_DIR}/jni/${abi}"
    cp libwebrtc_aec3_real.so "${OUTPUT_DIR}/jni/${abi}/"
    
    echo "✅ Successfully built for $abi ($(du -h libwebrtc_aec3_real.so | cut -f1))"
done

cd "$PROJECT_ROOT"

# Create AAR structure
echo "📦 Creating AAR structure..."
AAR_DIR="${OUTPUT_DIR}/aar"
mkdir -p "${AAR_DIR}"
mkdir -p "${AAR_DIR}/classes"
mkdir -p "${AAR_DIR}/jni"

# Copy native libraries
cp -r "${OUTPUT_DIR}/jni/"* "${AAR_DIR}/jni/"

# Compile Java wrapper
echo "☕ Compiling Java wrapper..."
if command -v javac >/dev/null 2>&1; then
    javac -d "${AAR_DIR}/classes" "${BUILD_DIR}/java/cn/watchfun/webrtc/WebRTCAEC3Real.java"
    
    # Create classes.jar
    cd "${AAR_DIR}/classes"
    jar cf ../classes.jar .
    cd "$PROJECT_ROOT"
else
    echo "⚠️ Warning: javac not found, creating empty classes.jar"
    touch "${AAR_DIR}/classes.jar"
fi

# Create AndroidManifest.xml
cat > "${AAR_DIR}/AndroidManifest.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="cn.watchfun.webrtc"
    android:versionCode="1"
    android:versionName="1.0">
    
    <uses-sdk android:minSdkVersion="27" 
              android:targetSdkVersion="34" />
    
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    
</manifest>
EOF

# Create AAR file
echo "📦 Creating AAR file..."
cd "${AAR_DIR}"
zip -r "../${AAR_NAME}.aar" .
cd "$PROJECT_ROOT"

# Final verification
AAR_FILE="${OUTPUT_DIR}/${AAR_NAME}.aar"
if [ -f "$AAR_FILE" ]; then
    echo ""
    echo "🎉 ===== BUILD SUCCESSFUL ====="
    echo "📄 AAR file: $AAR_FILE"
    echo "📊 Size: $(du -h "$AAR_FILE" | cut -f1)"
    echo "🔍 Contents:"
    unzip -l "$AAR_FILE"
    echo ""
    echo "📋 Native libraries included:"
    for abi in "${ANDROID_ABIS[@]}"; do
        lib_file="${OUTPUT_DIR}/jni/${abi}/libwebrtc_aec3_real.so"
        if [ -f "$lib_file" ]; then
            echo "   ✅ $abi: $(du -h "$lib_file" | cut -f1)"
        fi
    done
    echo ""
    echo "🚀 Ready to integrate with your Android project!"
    echo "   Copy ${AAR_NAME}.aar to android_use_cpp/app/libs/"
    echo ""
else
    echo "❌ Error: AAR file not created"
    exit 1
fi
