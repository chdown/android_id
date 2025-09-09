package dev.fluttercommunity.android_id;

import android.os.Build;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class EmulatorCheck {

    // #region Files String
    private static ArrayList<String> GENY_FILES = new ArrayList<>(
            Arrays.asList(
                    "/dev/socket/genyd",
                    "/dev/socket/baseband_genyd"));

    private static ArrayList<String> PIPES = new ArrayList<>(
            Arrays.asList(
                    "/dev/socket/qemud",
                    "/dev/qemu_pipe"));

    private static ArrayList<String> X86_FILES = new ArrayList<>(
            Arrays.asList(
                    "ueventd.android_x86.rc",
                    "x86.prop",
                    "ueventd.ttVM_x86.rc",
                    "init.ttVM_x86.rc",
                    "fstab.ttVM_x86",
                    "fstab.vbox86",
                    "init.vbox86.rc",
                    "ueventd.vbox86.rc"));

    private static ArrayList<String> ANDY_FILES = new ArrayList<>(
            Arrays.asList(
                    "fstab.andy",
                    "ueventd.andy.rc"));

    private static ArrayList<String> NOX_FILES = new ArrayList<>(
            Arrays.asList(
                    "fstab.nox",
                    "init.nox.rc",
                    "ueventd.nox.rc"));

    private static ArrayList<String> LDPLAYER_FILES = new ArrayList<>(
            Arrays.asList(
                    "/system/lib/libc_malloc_debug_qemu.so",
                    "/system/bin/microvirt-prop",
                    "/system/bin/microvirt-uiautomator",
                    "/system/bin/microvirtd",
                    "/system/xbin/microvirt-prop"));

    private static ArrayList<String> MEMU_FILES = new ArrayList<>(
            Arrays.asList(
                    "fstab.memu",
                    "init.memu.rc",
                    "ueventd.memu.rc"));
    // #endregion

    // #region Methods
    public static boolean isEmulator() {
        return Build.FINGERPRINT.startsWith("generic")
                || Build.FINGERPRINT.startsWith("unknown")
                || Build.MODEL.contains("google_sdk")
                || Build.MODEL.contains("Emulator")
                || Build.MODEL.contains("Android SDK built for x86")
                || Build.MANUFACTURER.contains("Genymotion")
                || Build.MODEL.startsWith("sdk_")
                || Build.DEVICE.startsWith("emulator")
                || (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
                || "google_sdk".equals(Build.PRODUCT)
                // bluestacks
                || "QC_Reference_Phone".equals(Build.BOARD) && !"xiaomi".equalsIgnoreCase(Build.MANUFACTURER)
                // bluestacks
                || Build.MANUFACTURER.contains("Genymotion")
                || (Build.HOST.startsWith("Build") && !Build.MANUFACTURER.equalsIgnoreCase("sony"))
                // MSI App Player
                || Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")
                || "google_sdk".equals(Build.PRODUCT)
                // another Android SDK emulator check
                || "1".equals(SystemProperties.get("ro.kernel.qemu"))
                || Build.HARDWARE.contains("goldfish")
                || Build.HARDWARE.contains("ranchu")
                || Build.PRODUCT.contains("vbox86p")
                || Build.PRODUCT.toLowerCase().contains("nox")
                || Build.BOARD.toLowerCase().contains("nox")
                || Build.HARDWARE.toLowerCase().contains("nox")
                || Build.MODEL.toLowerCase().contains("droid4x")
                || "vbox86".equals(Build.HARDWARE)
                // LDPlayer specific checks
                || isLDPlayer()
                // MEmu specific checks
                || isMEmu()
                // BlueStacks specific checks
                || isBlueStacks()
                // Enhanced architecture check
                || isX86Architecture()
                || checkEmulatorFiles();
    }

    /**
     * Enhanced LDPlayer detection
     */
    private static boolean isLDPlayer() {
        return Build.MANUFACTURER.toLowerCase().contains("changwan")
                || Build.BRAND.toLowerCase().contains("changwan")
                || Build.MODEL.toLowerCase().contains("changwan")
                || Build.DEVICE.toLowerCase().contains("changwan")
                || Build.PRODUCT.toLowerCase().contains("changwan")
                || Build.FINGERPRINT.toLowerCase().contains("changwan")
                || Build.MANUFACTURER.toLowerCase().contains("ldplayer")
                || Build.BRAND.toLowerCase().contains("ldplayer")
                || Build.MODEL.toLowerCase().contains("ldplayer")
                || Build.HARDWARE.toLowerCase().contains("lkm")
                || Build.HARDWARE.toLowerCase().contains("ttvm")
                || "LDPlayer".equals(Build.MODEL)
                || "Chang Wan".equals(Build.MANUFACTURER)
                || "ttVM_Hdragon".equals(Build.DEVICE)
                || Build.FINGERPRINT.contains("LDPlayer")
                || checkFiles(LDPLAYER_FILES);
    }

    /**
     * Enhanced MEmu detection
     */
    private static boolean isMEmu() {
        return Build.MANUFACTURER.toLowerCase().contains("memu")
                || Build.BRAND.toLowerCase().contains("memu")
                || Build.MODEL.toLowerCase().contains("memu")
                || Build.DEVICE.toLowerCase().contains("memu")
                || Build.PRODUCT.toLowerCase().contains("memu")
                || "Microvirt".equals(Build.MANUFACTURER)
                || "MEmu".equals(Build.MODEL)
                || Build.HARDWARE.toLowerCase().contains("memu")
                || checkFiles(MEMU_FILES);
    }

    /**
     * Enhanced BlueStacks detection
     */
    private static boolean isBlueStacks() {
        return Build.MANUFACTURER.toLowerCase().contains("bluestacks")
                || Build.BRAND.toLowerCase().contains("bluestacks")
                || Build.MODEL.toLowerCase().contains("bluestacks")
                || Build.DEVICE.toLowerCase().contains("bluestacks")
                || Build.PRODUCT.toLowerCase().contains("bluestacks")
                || "BlueStacks".equals(Build.MANUFACTURER)
                || "QC_Reference_Phone".equals(Build.BOARD) && !"xiaomi".equalsIgnoreCase(Build.MANUFACTURER);
    }

    /**
     * Enhanced x86 architecture detection
     */
    private static boolean isX86Architecture() {
        try {
            String arch = System.getProperty("os.arch");
            return arch != null && (arch.contains("x86") || arch.contains("i686"));
        } catch (Exception e) {
            return false;
        }
    }
    // #endregion

    // #region Utils
    private static boolean checkFiles(List<String> targets) {
        for (String pipe : targets) {
            File file = new File(pipe);
            if (file.exists())
                return true;
        }
        return false;
    }

    private static boolean checkEmulatorFiles() {
        return (checkFiles(GENY_FILES)
                || checkFiles(ANDY_FILES)
                || checkFiles(NOX_FILES)
                || checkFiles(X86_FILES)
                || checkFiles(PIPES)
                || checkFiles(LDPLAYER_FILES)
                || checkFiles(MEMU_FILES));
    }

    /**
     * 获取设备常用信息
     */
    public static java.util.Map<String, Object> getDeviceInfo() {
        java.util.Map<String, Object> deviceInfo = new java.util.HashMap<>();
        deviceInfo.put("manufacturer", Build.MANUFACTURER);
        deviceInfo.put("brand", Build.BRAND);
        deviceInfo.put("model", Build.MODEL);
        deviceInfo.put("device", Build.DEVICE);
        deviceInfo.put("product", Build.PRODUCT);
        deviceInfo.put("board", Build.BOARD);
        deviceInfo.put("hardware", Build.HARDWARE);
        deviceInfo.put("host", Build.HOST);
        deviceInfo.put("fingerprint", Build.FINGERPRINT);
        deviceInfo.put("bootloader", Build.BOOTLOADER);
        deviceInfo.put("radioVersion", Build.getRadioVersion());
        deviceInfo.put("osVersion", Build.VERSION.RELEASE);
        deviceInfo.put("sdkInt", Build.VERSION.SDK_INT);
        deviceInfo.put("incremental", Build.VERSION.INCREMENTAL);
        deviceInfo.put("codename", Build.VERSION.CODENAME);
        deviceInfo.put("architecture", System.getProperty("os.arch") != null ? System.getProperty("os.arch") : "unknown");
        deviceInfo.put("javaVmName", System.getProperty("java.vm.name") != null ? System.getProperty("java.vm.name") : "unknown");
        deviceInfo.put("javaVmVersion", System.getProperty("java.vm.version") != null ? System.getProperty("java.vm.version") : "unknown");
        return deviceInfo;
    }

    /**
     * 检查文件数组中存在的文件
     */
    public static java.util.List<String> checkFilesExist(java.util.List<String> filePaths) {
        java.util.List<String> existingFiles = new java.util.ArrayList<>();
        
        for (String filePath : filePaths) {
            try {
                File file = new File(filePath);
                if (file.exists()) {
                    existingFiles.add(filePath);
                }
            } catch (Exception e) {
                // 忽略无法访问的文件，继续检查其他文件
            }
        }
        
        return existingFiles;
    }
    // #endregion
}
