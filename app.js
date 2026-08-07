const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

class ContourField {
  constructor(canvas, options = {}) {
    this.canvas = canvas;
    this.context = canvas.getContext("2d");
    this.options = {
      rings: options.rings || 18,
      spacing: options.spacing || 27,
      centerX: options.centerX || 0.5,
      centerY: options.centerY || 0.5,
      speed: options.speed || 0.00012,
      accentRing: options.accentRing ?? 3,
      opacity: options.opacity || 0.28,
      animated: options.animated ?? true
    };
    this.pointer = {
      x: 0,
      y: 0,
      targetX: 0,
      targetY: 0,
      energy: 0,
      targetEnergy: 0
    };
    this.visible = true;
    this.frame = null;
    this.resizeObserver = new ResizeObserver(() => this.resize());
    this.resizeObserver.observe(canvas);
    this.intersectionObserver = new IntersectionObserver((entries) => {
      this.visible = entries[0].isIntersecting;
      if (this.options.animated && this.visible && !this.frame && !reducedMotion) {
        this.animate(performance.now());
      }
    });
    this.intersectionObserver.observe(canvas);
    this.resize();
  }

  resize() {
    const rect = this.canvas.getBoundingClientRect();
    const ratio = Math.min(window.devicePixelRatio || 1, 2);
    this.canvas.width = Math.max(1, Math.round(rect.width * ratio));
    this.canvas.height = Math.max(1, Math.round(rect.height * ratio));
    this.context.setTransform(ratio, 0, 0, ratio, 0, 0);
    this.width = rect.width;
    this.height = rect.height;
    this.draw(reducedMotion ? 0 : performance.now());
  }

  draw(time) {
    const ctx = this.context;
    const { rings, spacing, centerX, centerY, speed, accentRing, opacity } = this.options;
    const phase = time * speed;
    const pointerMagnitude = Math.min(1, Math.hypot(this.pointer.x, this.pointer.y));
    const pointerAngle = Math.atan2(this.pointer.y, this.pointer.x);
    const cx = this.width * centerX + this.pointer.x * 24;
    const cy = this.height * centerY + this.pointer.y * 18;

    ctx.clearRect(0, 0, this.width, this.height);
    ctx.lineCap = "round";
    ctx.lineJoin = "round";

    for (let ring = 0; ring < rings; ring += 1) {
      const base = 18 + ring * spacing;
      const points = 112;
      ctx.beginPath();

      for (let point = 0; point <= points; point += 1) {
        const angle = (point / points) * Math.PI * 2;
        const pointerFlow =
          Math.cos(angle - pointerAngle) *
          pointerMagnitude *
          this.pointer.energy *
          Math.max(0, 1 - ring / rings) *
          12;
        const wobble =
          Math.sin(angle * 3 + phase + ring * 0.34) * (4.8 + ring * 0.18) +
          Math.sin(angle * 5 - phase * 0.7 + ring * 0.2) * (2.4 + ring * 0.08) +
          Math.cos(angle * 2 + ring * 0.45) * 2.5 +
          pointerFlow;
        const stretchX = 1 + Math.sin(ring * 0.28) * 0.05;
        const stretchY = 0.88 + Math.cos(ring * 0.23) * 0.06;
        const x = cx + Math.cos(angle) * (base + wobble) * stretchX;
        const y = cy + Math.sin(angle) * (base + wobble) * stretchY;

        if (point === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
      }

      const isAccent = ring === accentRing;
      ctx.strokeStyle = isAccent
        ? "rgba(47, 99, 233, 0.92)"
        : `rgba(22, 22, 21, ${opacity})`;
      ctx.lineWidth = isAccent ? 1.45 : 0.8;
      ctx.stroke();
    }
  }

  animate = (time) => {
    this.frame = null;
    if (!this.options.animated || !this.visible || reducedMotion) return;
    this.pointer.x += (this.pointer.targetX - this.pointer.x) * 0.075;
    this.pointer.y += (this.pointer.targetY - this.pointer.y) * 0.075;
    this.pointer.energy += (this.pointer.targetEnergy - this.pointer.energy) * 0.09;
    this.draw(time);
    this.frame = requestAnimationFrame(this.animate);
  };

  bindPointer(element) {
    if (!element || reducedMotion) return;

    element.addEventListener("pointermove", (event) => {
      const rect = element.getBoundingClientRect();
      this.pointer.targetX = (event.clientX - rect.left) / rect.width - 0.5;
      this.pointer.targetY = (event.clientY - rect.top) / rect.height - 0.5;
      this.pointer.targetEnergy = 1;
    });

    element.addEventListener("pointerleave", () => {
      this.pointer.targetX = 0;
      this.pointer.targetY = 0;
      this.pointer.targetEnergy = 0;
    });
  }

  start() {
    if (this.options.animated && !reducedMotion && !this.frame) {
      this.frame = requestAnimationFrame(this.animate);
    }
  }
}

const entryField = new ContourField(document.getElementById("entryContours"), {
  rings: 24,
  spacing: 34,
  centerX: 0.48,
  centerY: 0.55,
  speed: 0.00028,
  accentRing: 4,
  opacity: 0.18
});

const heroField = new ContourField(document.getElementById("heroContours"), {
  rings: 22,
  spacing: 28,
  centerX: 0.46,
  centerY: 0.5,
  speed: 0.0002,
  accentRing: 2,
  opacity: 0.34
});

const worksContourOptions = {
  rings: 9,
  spacing: 14,
  centerX: 0.5,
  centerY: 0.5,
  accentRing: -1,
  opacity: 0.16,
  animated: false
};

new ContourField(document.getElementById("worksContourRight"), {
  ...worksContourOptions,
  rings: 13,
  spacing: 22,
  centerY: 0.18
});
new ContourField(document.getElementById("worksContourLeft"), {
  ...worksContourOptions,
  centerX: 0.46,
  centerY: 0.53
});

entryField.start();
heroField.start();

const entry = document.getElementById("entry");
const enterButton = document.getElementById("enterButton");
const heroRing = document.getElementById("heroRing");
let hasEntered = false;

entryField.bindPointer(enterButton);
heroField.bindPointer(heroRing);

function enterSite() {
  if (hasEntered) return;
  hasEntered = true;
  entry.classList.add("is-leaving");
  document.body.classList.add("site-ready");

  const delay = reducedMotion ? 20 : 950;
  window.setTimeout(() => {
    entry.hidden = true;
    document.body.classList.remove("is-locked");
  }, delay);
}

enterButton.addEventListener("click", enterSite);
document.addEventListener("keydown", (event) => {
  if (event.key === "Enter" && !hasEntered) enterSite();
});

const revealObserver = new IntersectionObserver((entries, observer) => {
  entries.forEach((entryItem) => {
    if (!entryItem.isIntersecting) return;
    entryItem.target.classList.add("is-visible");
    observer.unobserve(entryItem.target);
  });
}, { threshold: 0.14 });

document.querySelectorAll(".reveal").forEach((element) => revealObserver.observe(element));

const worksBoard = document.getElementById("project01Scene");
const worksRouteLayer = document.getElementById("worksRouteLayer");
const routeFocuses = [...document.querySelectorAll(".project-route-focus")];

// The route is a one-shot entrance cue: it starts when Works enters view,
// then stays complete. It is intentionally independent of pointer and scroll position.
if (worksBoard && worksRouteLayer) {
  let routeStarted = false;
  let routeCompleted = false;

  const lightProjectOnce = (focus) => {
    if (focus.dataset.reached === "true") return;
    focus.dataset.reached = "true";
    focus.classList.add("is-lit");
    window.setTimeout(() => {
      focus.classList.remove("is-lit");
      focus.classList.add("is-visited");
    }, 820);
  };

  const completeRoute = () => {
    routeCompleted = true;
    worksRouteLayer.classList.remove("is-route-drawing");
    worksBoard.classList.add("is-route-complete");
  };

  const startRoute = () => {
    if (routeStarted || routeCompleted) return;
    routeStarted = true;

    if (reducedMotion) {
      routeFocuses.forEach((focus) => focus.classList.add("is-visited"));
      completeRoute();
      return;
    }

    worksRouteLayer.classList.add("is-route-drawing");
    const lightTimings = [260, 760, 1260, 1760];
    routeFocuses.forEach((focus, index) => {
      window.setTimeout(() => lightProjectOnce(focus), lightTimings[index]);
    });
    window.setTimeout(completeRoute, 2380);
  };

  const routeStartObserver = new IntersectionObserver((entries, observer) => {
    if (!entries[0].isIntersecting) return;
    observer.disconnect();
    startRoute();
  }, { threshold: 0.12 });

  routeStartObserver.observe(worksBoard);
}

const projectCards = [...document.querySelectorAll(".project-hotspot")];

projectCards.forEach((card) => {
  let isPinned = false;

  const setActive = (active) => {
    card.classList.toggle("is-active", active);
  };

  card.addEventListener("pointerenter", () => setActive(true));
  card.addEventListener("pointerleave", () => {
    if (!isPinned) setActive(false);
  });
  card.addEventListener("focus", () => setActive(true));
  card.addEventListener("blur", () => {
    if (!isPinned) setActive(false);
  });
  card.addEventListener("click", () => {
    isPinned = !isPinned;
    card.setAttribute("aria-pressed", String(isPinned));
    setActive(isPinned);
  });
});
