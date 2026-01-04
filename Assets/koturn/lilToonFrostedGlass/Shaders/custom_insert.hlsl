float gaussian(float2 p, float stddev);
float4 sampleGrabTextureWithBlur(float4 positionSS);


/*!
 * @brief Sample `_GrabTexture` via Gaussian function.
 * @param [in] p  2D point.
 * @param [in] stddev  Standard deviation.
 * @return Sampled color.
 */
float4 sampleGrabTextureWithBlur(float4 positionSS)
{
    const float kernelSize = (float)_GaussKernelSize;
    const float2 d = abs(float2(ddx(positionSS.x), ddy(positionSS.y)));
    int2 sampleOffset;

    float4 color = float4(0.0, 0.0, 0.0, 0.0);
    float weightSum = 0.0;
    for (sampleOffset.x = -_GaussKernelSize; sampleOffset.x <= _GaussKernelSize; sampleOffset.x++) {
        for (sampleOffset.y = -_GaussKernelSize; sampleOffset.y <= _GaussKernelSize; sampleOffset.y++) {
            const float2 p = (float2)sampleOffset;
            const float weight = gaussian(p, _GaussStdDev);
            const float2 uv = (positionSS.xy + p * d) / positionSS.w;
            color += weight * LIL_SAMPLE_2D(_GrabTexture, lil_sampler_linear_clamp, uv);
            weightSum += weight;
        }
    }

    return color / weightSum;
}


/*!
 * @brief Gaussian function.
 * @param [in] p  2D point.
 * @param [in] stddev  Standard deviation.
 * @return Result of gaussian function.
 */
float gaussian(float2 p, float stddev)
{
    float stdvar = stddev * stddev;
    return exp(-(p.x * p.x + p.y * p.y) * 0.5f / stdvar) / (UNITY_TWO_PI * stdvar);
}
