using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IncomingWater : MonoBehaviour
{
	ParticleSystem particle;

	bool isPlaying = false;
	float timeSinceStart;

    // Start is called before the first frame update
    void Start()
    {
		particle = GetComponentInChildren<ParticleSystem>();
    }

    // Update is called once per frame
    void Update()
    {
		if (!isPlaying) {
			if (Camera.main.transform.position.y < -9f) {
				particle.Play();
				isPlaying = true;
			}else{
				return;
			}
		}

		timeSinceStart += Time.deltaTime;

		var t = timeSinceStart > 0.1f ? 1f : timeSinceStart / 0.1f;
		var rate = Mathf.Lerp(300f, 0f, t);

		var emission = particle.emission;
		emission.rateOverTime = rate;

    }
}
