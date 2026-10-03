/* ==========================================================================
   jQuery plugin settings and other scripts
   ========================================================================== */

$(document).ready(function () {
  const profilePage = document.body.classList.contains("profile-site");
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  // detect OS/browser preference
  const browserPref = window.matchMedia('(prefers-color-scheme: dark)').matches
    ? 'dark'
    : 'light';

  // Set the theme on page load or when explicitly called
  var setTheme = function (theme) {
    const use_theme =
      theme ||
      localStorage.getItem("theme") ||
      $("html").attr("data-theme") ||
      browserPref;

    if (use_theme === "dark") {
      $("html").attr("data-theme", "dark");
      $("#theme-icon").removeClass("fa-sun").addClass("fa-moon");
    } else if (use_theme === "light") {
      $("html").removeAttr("data-theme");
      $("#theme-icon").removeClass("fa-moon").addClass("fa-sun");
    }
    const themeLabel = use_theme === "dark" ? "Switch to light mode" : "Switch to dark mode";
    $("#theme-toggle").attr({ "aria-label": themeLabel, title: themeLabel });
  };

  setTheme();

  // if user hasn't chosen a theme, follow OS changes
  window
    .matchMedia('(prefers-color-scheme: dark)')
    .addEventListener("change", (e) => {
      if (!localStorage.getItem("theme")) {
        setTheme(e.matches ? "dark" : "light");
      }
    });

  // Toggle the theme manually
  var toggleTheme = function () {
    const current_theme = $("html").attr("data-theme");
    const new_theme = current_theme === "dark" ? "light" : "dark";
    localStorage.setItem("theme", new_theme);
    setTheme(new_theme);
  };

  $('#theme-toggle').on('click', toggleTheme);

  // Sticky footer
  var bumpIt = function () {
    if ($("body").hasClass("profile-site")) return;
    $("body").css("margin-bottom", $(".page__footer").outerHeight(true));
  },
    didResize = false;

  bumpIt();

  $(window).resize(function () {
    didResize = true;
  });
  setInterval(function () {
    if (didResize) {
      didResize = false;
      bumpIt();
    }
  }, 250);

  // FitVids init
  fitvids();

  // Follow menu drop down
  $(".author__urls-wrapper button").on("click", function () {
    const expanded = $(this).attr("aria-expanded") === "true";
    $(this).attr("aria-expanded", String(!expanded)).toggleClass("open", !expanded);
    $(this).siblings(".author__urls").stop(true, true).toggle(!expanded);
  });

  $(document).on("keydown", function (event) {
    if (event.key !== "Escape") return;
    const $contacts = $(".author__urls-wrapper button[aria-expanded='true']:visible");
    if ($contacts.length) {
      $contacts.trigger("click").trigger("focus");
    }
    const $more = $(".profile-contact-menu[open]");
    if ($more.length) {
      $more.removeAttr("open").find("summary").trigger("focus");
    }
  });

  $(document).on("click", function (event) {
    if (!$(event.target).closest(".profile-contact-menu").length) {
      $(".profile-contact-menu[open]").removeAttr("open");
    }
  });

  // End the initial news viewport on a complete entry, including wrapped mobile text.
  document.querySelectorAll(".profile-news-scroll").forEach(function (scroll) {
    const list = scroll.querySelector(".profile-news-list");
    if (!list || !list.children.length) return;
    const compact = window.matchMedia("(max-width: 639px)");
    const fitNews = function () {
      const count = Math.min(list.children.length, compact.matches ? 3 : 5);
      const first = list.children[0].getBoundingClientRect();
      const last = list.children[count - 1].getBoundingClientRect();
      scroll.style.setProperty("--profile-news-height", Math.ceil(last.bottom - first.top) + "px");
    };
    fitNews();
    compact.addEventListener("change", fitNews);
    if (window.ResizeObserver) {
      new ResizeObserver(fitNews).observe(list);
    } else {
      window.addEventListener("resize", fitNews);
    }
  });

  // Contain nested scrolling only when there is overflow; short lists leave the page free to scroll.
  document.querySelectorAll(".profile-scroll").forEach(function (scroll) {
    const hint = document.querySelector('[data-scroll-target="' + scroll.id + '"]');
    const frame = scroll.closest(".profile-scroll-frame");
    const updateEdges = function () {
      if (!frame) return;
      const end = Math.max(0, scroll.scrollHeight - scroll.clientHeight);
      const position = Math.max(0, Math.min(scroll.scrollTop, end));
      frame.dataset.scrollUp = String(end > 1 && position > 1);
      frame.dataset.scrollDown = String(end > 1 && position < end - 1);
    };
    const updateScrollable = function () {
      const scrollable = scroll.scrollHeight > scroll.clientHeight + 1;
      scroll.dataset.scrollable = String(scrollable);
      if (hint) hint.hidden = !scrollable;
      updateEdges();
    };
    updateScrollable();
    scroll.addEventListener("scroll", updateEdges, { passive: true });
    if (window.ResizeObserver) {
      const observer = new ResizeObserver(updateScrollable);
      observer.observe(scroll);
      if (scroll.firstElementChild) observer.observe(scroll.firstElementChild);
    } else {
      window.addEventListener("resize", updateScrollable);
      scroll.addEventListener("load", updateScrollable, true);
    }
  });

  // Restore the follow menu if toggled on a window resize
  jQuery(window).on('resize', function () {
    $(".author__urls-wrapper").each(function () {
      const $button = $(this).children("button");
      $(this).children(".author__urls").css("display", $button.is(":visible")
        ? ($button.attr("aria-expanded") === "true" ? "block" : "none") : "");
    });
  });

  // init smooth scroll, this needs to be slightly more than then fixed masthead height
  $("a").smoothScroll({ 
    offset: -75, // needs to match $masthead-height
    preventDefault: false,
    speed: window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 0 : 400,
  }); 

  // add lightbox class to all image links
  // Add "image-popup" to links ending in image extensions,
  // but skip any <a> that already contains an <img>
  $("a[href$='.jpg'],\
  a[href$='.jpeg'],\
  a[href$='.JPG'],\
  a[href$='.png'],\
  a[href$='.gif'],\
  a[href$='.webp']")
      .not(':has(img)')
      .addClass("image-popup");

  // 1) Wrap every <p><img> (except emoji images) in an <a> pointing at the image, and give it the lightbox class
  $('p > img').not('.emoji').each(function() {
    var $img = $(this);
    // skip if it’s already wrapped in an <a.image-popup>
    if ( ! $img.parent().is('a.image-popup') ) {
      $('<a>')
        .addClass('image-popup')
        .attr('href', $img.attr('src'))
        .insertBefore($img)   // place the <a> right before the <img>
        .append($img);        // move the <img> into the <a>
    }
  });

  // Magnific-Popup options
  $(".image-popup").magnificPopup({
    type: 'image',
    tLoading: 'Loading image #%curr%...',
    gallery: {
      enabled: true,
      navigateByImgClick: true,
      preload: [0, 1] // Will preload 0 - before current, and 1 after the current image
    },
    image: {
      tError: '<a href="%url%">Image #%curr%</a> could not be loaded.',
      titleSrc: profilePage ? function (item) {
        const title = item.el.attr("data-figure-title") || item.el.attr("title") || "";
        return $("<span>").text(title).html();
      } : 'title'
    },
    removalDelay: profilePage ? 200 : 500,
    mainClass: profilePage ? 'profile-image-preview' : 'mfp-zoom-in',
    callbacks: {
      open: function () {
        $(".mfp-wrap").attr({ "role": "dialog", "aria-modal": "true", "aria-label": "Image preview" });
        $(".mfp-close").attr("aria-label", "Close image preview");
      },
      beforeOpen: function () {
        if (profilePage) this.st.removalDelay = reducedMotion.matches ? 0 : 200;
        // just a hack that adds mfp-anim class to markup
        this.st.image.markup = this.st.image.markup.replace('mfp-figure', 'mfp-figure mfp-with-anim');
      },
      beforeClose: function () {
        if (profilePage) this.st.removalDelay = reducedMotion.matches ? 0 : 200;
      }
    },
    closeOnContentClick: true,
    midClick: true // allow opening popup on middle mouse click. Always set it to true if you don't provide alternative source.
  });

});
