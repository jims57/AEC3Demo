#!/usr/bin/env python3
"""
WebRTC AEC3 Dependency Analysis Script
Analyzes echo_canceller3.cc/.h and finds all required dependencies for building AAR
"""

import os
import re
import shutil
from pathlib import Path

# Base paths
AEC3_DEMO_ROOT = Path("/Users/mac/Documents/GitHub/AEC3Demo")
OUTPUT_DIR = AEC3_DEMO_ROOT / "my-info" / "my-aec3-files"

# Core files to analyze
CORE_FILES = [
    "modules/audio_processing/aec3/echo_canceller3.cc",
    "modules/audio_processing/aec3/echo_canceller3.h"
]

# Known essential AEC3 dependencies based on analysis
ESSENTIAL_DEPENDENCIES = {
    # Core AEC3 modules (the heart of echo cancellation)
    "modules/audio_processing/aec3/": [
        "echo_canceller3.cc", "echo_canceller3.h",
        "block_processor.cc", "block_processor.h",
        "echo_remover.cc", "echo_remover.h", 
        "subtractor.cc", "subtractor.h",
        "suppression_filter.cc", "suppression_filter.h",
        "render_buffer.cc", "render_buffer.h",
        "render_delay_controller.cc", "render_delay_controller.h",
        "render_delay_buffer.cc", "render_delay_buffer.h",
        "frame_blocker.cc", "frame_blocker.h",
        "block_framer.cc", "block_framer.h",
        "block_delay_buffer.cc", "block_delay_buffer.h",
        "config_selector.cc", "config_selector.h",
        "multi_channel_content_detector.cc", "multi_channel_content_detector.h",
        "api_call_jitter_metrics.cc", "api_call_jitter_metrics.h",
        "aec3_common.h", "aec3_fft.cc", "aec3_fft.h",
        "adaptive_fir_filter.cc", "adaptive_fir_filter.h",
        "filter_analyzer.cc", "filter_analyzer.h",
        "main_filter_update_gain.cc", "main_filter_update_gain.h",
        "shadow_filter_update_gain.cc", "shadow_filter_update_gain.h",
        "erle_estimator.cc", "erle_estimator.h",
        "fullband_erle_estimator.cc", "fullband_erle_estimator.h",
        "subband_erle_estimator.cc", "subband_erle_estimator.h",
        "signal_dependent_erle_estimator.cc", "signal_dependent_erle_estimator.h",
        "erl_estimator.cc", "erl_estimator.h",
        "echo_path_delay_estimator.cc", "echo_path_delay_estimator.h",
        "echo_path_variability.cc", "echo_path_variability.h",
        "residual_echo_estimator.cc", "residual_echo_estimator.h",
        "reverb_model.cc", "reverb_model.h",
        "reverb_model_estimator.cc", "reverb_model_estimator.h",
        "reverb_decay_estimator.cc", "reverb_decay_estimator.h",
        "reverb_frequency_response.cc", "reverb_frequency_response.h",
        "render_signal_analyzer.cc", "render_signal_analyzer.h",
        "subtractor_output.cc", "subtractor_output.h",
        "subtractor_output_analyzer.cc", "subtractor_output_analyzer.h",
        "suppression_gain.cc", "suppression_gain.h",
        "subband_nearend_detector.cc", "subband_nearend_detector.h",
        "stationarity_estimator.cc", "stationarity_estimator.h",
        "spectrum_buffer.cc", "spectrum_buffer.h",
        "fft_buffer.cc", "fft_buffer.h", 
        "fft_data.h",
        "moving_average.cc", "moving_average.h",
        "matched_filter.cc", "matched_filter.h",
        "matched_filter_lag_aggregator.cc", "matched_filter_lag_aggregator.h",
        "vector_math.h"
    ],
    
    # Audio processing support
    "modules/audio_processing/": [
        "audio_buffer.cc", "audio_buffer.h",
        "high_pass_filter.cc", "high_pass_filter.h",
        "splitting_filter.cc", "splitting_filter.h", 
        "three_band_filter_bank.cc", "three_band_filter_bank.h",
        "channel_buffer.cc", "channel_buffer.h"
    ],
    
    # Audio processing utilities
    "modules/audio_processing/utility/": [
        "audio_frame_operations.cc", "audio_frame_operations.h",
        "cascaded_biquad_filter.cc", "cascaded_biquad_filter.h",
        "ooura_fft.cc", "ooura_fft.h",
        "ooura_fft_tables_common.h",
        "ooura_fft_tables_neon_sse2.h"
    ],
    
    # Audio processing logging
    "modules/audio_processing/logging/": [
        "apm_data_dumper.cc", "apm_data_dumper.h"
    ],
    
    # API headers
    "api/audio/": [
        "echo_control.h",
        "echo_canceller3_config.h", "echo_canceller3_config.cc",
        "echo_canceller3_factory.h", "echo_canceller3_factory.cc"
    ],
    
    "api/": [
        "array_view.h"
    ],
    
    # Common audio utilities
    "common_audio/": [
        "real_fourier.cc", "real_fourier.h",
        "real_fourier_ooura.cc", "real_fourier_ooura.h", 
        "audio_util.cc", "audio_util.h"
    ],
    
    "common_audio/third_party/ooura/": [
        "fft_size_128/ooura_fft.cc", "fft_size_128/ooura_fft.h",
        "fft_size_256/ooura_fft.cc", "fft_size_256/ooura_fft.h"
    ],
    
    "common_audio/signal_processing/": [
        "complex_fft.c", "real_fft.c", "spl_init.c",
        "include/signal_processing_library.h",
        "include/spl_inl.h"
    ],
    
    # RTC base utilities
    "rtc_base/": [
        "checks.cc", "checks.h",
        "logging.cc", "logging.h", 
        "race_checker.cc", "race_checker.h",
        "swap_queue.h", "thread_annotations.h",
        "aligned_malloc.cc", "aligned_malloc.h",
        "string_to_number.cc", "string_to_number.h"
    ],
    
    "rtc_base/experiments/": [
        "field_trial_parser.cc", "field_trial_parser.h"
    ],
    
    # System wrappers
    "system_wrappers/": [
        "include/field_trial.h"
    ],
    
    "system_wrappers/source/": [
        "field_trial.cc"
    ],
    
    # ABSL dependencies (minimal stubs needed)
    "third_party/abseil-cpp/absl/strings/": [
        "string_view.h"
    ],
    
    "third_party/abseil-cpp/absl/types/": [
        "optional.h"
    ]
}

def find_include_dependencies(file_path):
    """Extract #include statements from a C++ file"""
    includes = []
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            # Find all #include statements
            include_pattern = r'#include\s*[<"]([^>"]+)[>"]'
            matches = re.findall(include_pattern, content)
            includes.extend(matches)
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
    return includes

def copy_file_if_exists(src_path, dst_path):
    """Copy file if it exists, create directories if needed"""
    if src_path.exists():
        dst_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src_path, dst_path)
        print(f"Copied: {src_path} -> {dst_path}")
        return True
    else:
        print(f"Missing: {src_path}")
        return False

def analyze_and_copy_dependencies():
    """Main function to analyze dependencies and copy files"""
    print("🔍 Starting WebRTC AEC3 dependency analysis...")
    
    # Clean and create output directory
    if OUTPUT_DIR.exists():
        shutil.rmtree(OUTPUT_DIR)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    total_files = 0
    copied_files = 0
    
    # Copy all essential dependencies
    for dir_path, file_list in ESSENTIAL_DEPENDENCIES.items():
        for filename in file_list:
            src_path = AEC3_DEMO_ROOT / dir_path / filename
            dst_path = OUTPUT_DIR / dir_path / filename
            
            total_files += 1
            if copy_file_if_exists(src_path, dst_path):
                copied_files += 1
    
    print(f"\n📊 Summary:")
    print(f"Total files needed: {total_files}")
    print(f"Successfully copied: {copied_files}")
    print(f"Missing files: {total_files - copied_files}")
    print(f"Output directory: {OUTPUT_DIR}")
    
    # Analyze core files for additional dependencies
    print(f"\n🔍 Analyzing core AEC3 files for additional dependencies...")
    for core_file in CORE_FILES:
        file_path = AEC3_DEMO_ROOT / core_file
        if file_path.exists():
            includes = find_include_dependencies(file_path)
            print(f"\n{core_file} includes:")
            for inc in includes[:10]:  # Show first 10 includes
                print(f"  - {inc}")
    
    return copied_files, total_files

if __name__ == "__main__":
    copied, total = analyze_and_copy_dependencies()
    print(f"\n✅ Dependency analysis complete! Copied {copied}/{total} files.")
    print(f"📁 Files organized in: {OUTPUT_DIR}")
