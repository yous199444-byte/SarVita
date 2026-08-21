(() => {
  'use strict';

  const video = document.querySelector('#sarvita-home-video video');
  if (video) {
    video.addEventListener('error', () => {
      const container = document.querySelector('#sarvita-home-video');
      if (container) container.classList.add('sarvita-home-video--unavailable');
    }, { once: true });

    const play = video.play();
    if (play?.catch) play.catch(() => {
      // Autoplay can be blocked by a browser; native controls remain available.
    });
  }

  window.addEventListener('load', () => {
    document.body.classList.add('sarvita-arc-ready');
  }, { once: true });
})();
