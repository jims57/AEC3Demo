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
