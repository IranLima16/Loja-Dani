/* TOOLA ONE - comportamentos da vitrine.
   Portado de index.html. O seletor de edicoes agora le as variantes reais
   do produto (data-* escritos pelo Liquid) em vez de um array fixo. */
(function () {
  document.documentElement.classList.add('js');

  /* ---------- seletor de edicoes ---------- */
  function initEditions(root) {
    var stage = root.querySelector('[data-ed-stage]');
    if (!stage) return;

    var els = {
      sw: stage.querySelector('[data-ed-swatch]'),
      tag: stage.querySelector('[data-ed-tag]'),
      img: stage.querySelector('[data-ed-img]'),
      n: stage.querySelector('[data-ed-name-out]'),
      p: stage.querySelector('[data-ed-person-out]'),
      d: stage.querySelector('[data-ed-desc-out]'),
      h: stage.querySelector('[data-ed-hw-out]'),
      cta: stage.querySelector('[data-ed-cta]'),
      form: stage.querySelector('[data-ed-variant-input]')
    };
    var btns = stage.querySelectorAll('[data-ed-btn]');

    function apply(btn) {
      var d = btn.dataset;
      if (els.sw) els.sw.style.background = d.edHex || '#1A1A1A';
      if (els.n) els.n.textContent = d.edName || '';
      if (els.p) els.p.textContent = d.edPerson || '';
      if (els.d) els.d.textContent = d.edDesc || '';
      if (els.h) els.h.textContent = d.edHw || '';
      if (els.cta) els.cta.textContent = d.edLabel || '';
      if (els.tag) els.tag.textContent = d.edTag || '';
      if (els.form && d.edVariant) els.form.value = d.edVariant;

      /* troca a foto da cor quando o produto tem imagem na variante */
      if (els.img && d.edImage) {
        els.img.src = d.edImage;
        els.img.srcset = d.edImageSrcset || '';
        els.img.alt = d.edImageAlt || d.edName || '';
        els.img.hidden = false;
        if (els.sw) els.sw.hidden = true;
      }

      btns.forEach(function (b) {
        b.setAttribute('aria-pressed', b === btn ? 'true' : 'false');
      });
    }

    btns.forEach(function (b) {
      b.addEventListener('click', function () { apply(b); });
    });

    var first = stage.querySelector('[data-ed-btn][aria-pressed="true"]') || btns[0];
    if (first) apply(first);
  }

  /* ---------- barra de compra fixa no mobile ---------- */
  function initBuybar() {
    var bar = document.querySelector('[data-buybar]');
    var top = document.querySelector('[data-buybar-trigger]');
    if (!bar || !top || !('IntersectionObserver' in window)) return;
    new IntersectionObserver(function (es) {
      es.forEach(function (en) { bar.classList.toggle('on', !en.isIntersecting); });
    }, { threshold: 0 }).observe(top);
  }

  /* ---------- animacao de entrada ---------- */
  function initReveal(root) {
    var items = root.querySelectorAll('.reveal');
    var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reduce || !('IntersectionObserver' in window)) {
      items.forEach(function (el) { el.classList.add('in'); });
      return;
    }
    var io = new IntersectionObserver(function (es) {
      es.forEach(function (en) {
        if (en.isIntersecting) { en.target.classList.add('in'); io.unobserve(en.target); }
      });
    }, { rootMargin: '0px 0px -8% 0px', threshold: 0.08 });
    items.forEach(function (el) { io.observe(el); });
  }

  function boot(root) {
    initEditions(root);
    initReveal(root);
  }

  document.addEventListener('DOMContentLoaded', function () {
    boot(document);
    initBuybar();
  });

  /* o editor de temas recarrega uma secao por vez, sem recarregar a pagina */
  document.addEventListener('shopify:section:load', function (e) {
    boot(e.target);
    initBuybar();
  });
})();
