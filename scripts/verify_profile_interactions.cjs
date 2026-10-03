const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const source = fs.readFileSync(path.join(__dirname, "../assets/js/_main.js"), "utf8");
let checks = 0;
function equal(actual, expected) {
  assert.deepEqual(actual, expected);
  checks++;
}

function setup({ profile = true, reduced = false, withFrame = true } = {}) {
  const frame = { dataset: {} };
  const hint = { hidden: true };
  const events = {};
  const observers = [];
  const motion = { matches: reduced, addEventListener() {} };
  const scroll = {
    id: "publication-list", dataset: {}, scrollTop: 0, scrollHeight: 900, clientHeight: 500,
    firstElementChild: {},
    closest: () => withFrame ? frame : null,
    addEventListener: (name, callback) => { events[name] = callback; }
  };
  let popup;
  const chain = {};
  for (const method of ["on", "attr", "removeAttr", "removeClass", "addClass", "resize", "not", "each", "smoothScroll"])
    chain[method] = () => chain;
  chain.ready = callback => callback();
  chain.hasClass = () => true;
  chain.magnificPopup = options => { popup = options; };
  const document = {
    body: { classList: { contains: () => profile } },
    querySelectorAll: selector => selector === ".profile-scroll" ? [scroll] : [],
    querySelector: () => hint
  };
  const window = {
    matchMedia: query => query.includes("reduced-motion") ? motion : { matches: false, addEventListener() {} }
  };
  const jquery = () => chain;
  vm.runInNewContext(source, {
    document, window, $: jquery, jQuery: jquery,
    localStorage: { getItem: () => "light" },
    fitvids() {}, setInterval() {},
    ResizeObserver: window.ResizeObserver = class {
      constructor(callback) { observers.push(callback); }
      observe() {}
    }
  });
  return { frame, hint, scroll, events, observers, motion, popup };
}

const state = setup();
function edges(up, down) {
  equal(state.frame.dataset.scrollUp, String(up));
  equal(state.frame.dataset.scrollDown, String(down));
}
equal(state.scroll.dataset.scrollable, "true");
equal(state.hint.hidden, false);
edges(false, true);
for (const [position, up, down] of [[100, true, true], [400, true, false], [450, true, false], [-30, false, true], [0, false, true]]) {
  state.scroll.scrollTop = position;
  state.events.scroll();
  edges(up, down);
}
// Resizing or replacing content must clear stale edge state and scroll containment.
state.scroll.scrollTop = 200;
state.scroll.scrollHeight = 400;
state.observers.forEach(update => update());
equal(state.scroll.dataset.scrollable, "false");
equal(state.hint.hidden, true);
edges(false, false);
state.scroll.scrollTop = 0;
state.scroll.scrollHeight = 900;
state.observers.forEach(update => update());
edges(false, true);
const noFrame = setup({ withFrame: false });
noFrame.events.scroll();
equal(noFrame.scroll.dataset.scrollable, "true");

for (const reduced of [false, true]) {
  const { popup, motion } = setup({ reduced });
  const context = { st: { ...popup, image: { ...popup.image, markup: "mfp-figure" } } };
  equal(popup.mainClass, "profile-image-preview");
  popup.callbacks.beforeOpen.call(context);
  equal(context.st.removalDelay, reduced ? 0 : 200);
  // Respect a preference change while the image preview is already open.
  motion.matches = !reduced;
  popup.callbacks.beforeClose.call(context);
  equal(context.st.removalDelay, reduced ? 200 : 0);
}
const legacy = setup({ profile: false }).popup;
equal(legacy.mainClass, "mfp-zoom-in");
equal(legacy.removalDelay, 500);

console.log(`${checks} profile interaction checks passed.`);
