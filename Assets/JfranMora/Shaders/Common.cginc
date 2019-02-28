float remap(float value, float from1, float to1, float from2, float to2) {
    return from2 + (value - from1) * (to2 - from2) / (to1 - from1);
}