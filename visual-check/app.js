const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

class ContourField {
  constructor(canvas, options = {}) {
    this.canvas = canvas;
    this.context = canvas?.getContext("2d");
    if (!this.context) return;
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
    this.pointer = { x: 0, y: 0, targetX: 0, targetY: 0, energy: 0, targetEnergy: 0 };
    this.visible = true;
    this.frame = null;
    this.resizeObserver = new ResizeObserver(() => this.resize());
    this.resizeObserver.observe(canvas);
    this.intersectionObserver = new IntersectionObserver((entries) => {
      this.visible = entries[0].isIntersecting;
      if (this.options.animated && this.visible && !this.frame && !reducedMotion) this.animate(performance.now());
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
        const pointerFlow = Math.cos(angle - pointerAngle) * pointerMagnitude * this.pointer.energy * Math.max(0, 1 - ring / rings) * 12;
        const wobble = Math.sin(angle * 3 + phase + ring * 0.34) * (4.8 + ring * 0.18)
          + Math.sin(angle * 5 - phase * 0.7 + ring * 0.2) * (2.4 + ring * 0.08)
          + Math.cos(angle * 2 + ring * 0.45) * 2.5
          + pointerFlow;
        const stretchX = 1 + Math.sin(ring * 0.28) * 0.05;
        const stretchY = 0.88 + Math.cos(ring * 0.23) * 0.06;
        const x = cx + Math.cos(angle) * (base + wobble) * stretchX;
        const y = cy + Math.sin(angle) * (base + wobble) * stretchY;
        if (point === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
      }

      const isAccent = ring === accentRing;
      ctx.strokeStyle = isAccent ? "rgba(47, 99, 233, 0.92)" : `rgba(22, 22, 21, ${opacity})`;
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
    if (this.options.animated && !reducedMotion && !this.frame) this.frame = requestAnimationFrame(this.animate);
  }
}

const entry = document.getElementById("entry");
const enterButton = document.getElementById("enterButton");
const entryHint = enterButton?.querySelector(".entry-hint");
let hasEntered = false;

function enterSite() {
  if (hasEntered) return;
  hasEntered = true;
  enterButton.classList.add("is-unwinding");
  enterButton.setAttribute("aria-label", "正在打开马润萌的作品集");
  if (entryHint) entryHint.textContent = "线条正在展开";
  const unwindDelay = reducedMotion ? 20 : 1120;
  window.setTimeout(() => {
    entry.classList.add("is-leaving");
    document.body.classList.add("site-ready");
    window.setTimeout(() => {
      entry.hidden = true;
      document.body.classList.remove("is-locked");
    }, reducedMotion ? 20 : 950);
  }, unwindDelay);
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
}, { threshold: 0.12 });

document.querySelectorAll(".reveal").forEach((element) => revealObserver.observe(element));

const roleCopy = {
  dickies: {
    title: "Dickies / 李宁",
    items: [
      ["背景与问题", "从用户、场景与材料出发，先确认问题发生的真实位置。"],
      ["我的判断与动作", "参与产品定位与需求梳理，把观察转成团队可以继续讨论的方向。"],
      ["结果或沉淀", "建立了从现场观察到产品定义的工作起点。"]
    ]
  },
  "70mai": {
    title: "70mai",
    items: [
      ["背景与问题", "硬件、软件与服务同时变化，体验问题不能只靠单点修补。"],
      ["我的判断与动作", "把体验拆成软硬件边界、状态与协作规则，推动方案进入开发流程。"],
      ["结果或沉淀", "形成了在约束中做取舍，并持续验证的产品方法。"]
    ]
  },
  nio: {
    title: "蔚来",
    items: [
      ["背景与问题", "座舱是多系统共同工作的空间，一个判断需要被不同角色同时理解。"],
      ["我的判断与动作", "围绕规则定义、跨系统协同与数据闭环，明确体验在不同状态下如何落地。"],
      ["结果或沉淀", "更清楚地理解了产品经理如何让规则在协作中成立。"]
    ]
  }
};

const projectCopy = {
  pillar: {
    title: "A 柱补盲",
    items: [["问题", "在复杂道路场景中，驾驶者的视线与系统提醒存在盲区。"], ["判断", "将安全体验拆成可理解的规则、触发条件与跨系统协作。"], ["过程", "从场景定义开始，逐步明确体验边界与验证方式。"]]
  },
  weight: {
    title: "称重与余粮体系重构",
    items: [["问题", "硬件采集、状态展示与端云职责之间缺少一致的体验规则。"], ["判断", "先把状态、异常与责任边界摊开，再决定信息如何被看见。"], ["过程", "围绕软硬件协同建立可执行的状态体系。"]]
  },
  collar: {
    title: "米家智能宠物项圈",
    items: [["问题", "宠物与人的关系需要同时被理解为陪伴、设备与日常行为。"], ["判断", "从用户洞察出发，明确产品定义与硬件取舍。"], ["过程", "把使用场景、佩戴感受与功能边界放在同一张桌上讨论。"]]
  },
  poopnow: {
    title: "PoopNow",
    items: [["问题", "推荐策略需要被快速验证，也需要能独立交付。"], ["判断", "把推荐逻辑、内容结构与 AI 辅助开发拆成可以快速迭代的模块。"], ["过程", "从策略到上线完成一轮独立产品交付。"]]
  }
};

function renderDrawerContent(container, data) {
  container.innerHTML = `<h2 class="sr-only">${data.title}</h2>${data.items.map(([heading, copy]) => `<article><h3>${heading}</h3><p>${copy}</p></article>`).join("")}`;
}

function setupDrawer({ triggerSelector, drawerId, contentId, kickerId, copyMap }) {
  const drawer = document.getElementById(drawerId);
  const content = document.getElementById(contentId);
  const kicker = document.getElementById(kickerId);
  const triggers = [...document.querySelectorAll(triggerSelector)];
  const close = drawer.querySelector(".drawer-close");

  const closeDrawer = () => {
    drawer.hidden = true;
    triggers.forEach((trigger) => trigger.setAttribute("aria-expanded", "false"));
  };

  triggers.forEach((trigger) => {
    trigger.addEventListener("click", () => {
      const key = trigger.dataset.role || trigger.dataset.project;
      const isOpen = !drawer.hidden && trigger.getAttribute("aria-expanded") === "true";
      triggers.forEach((item) => item.setAttribute("aria-expanded", "false"));
      if (isOpen) {
        closeDrawer();
        return;
      }
      const data = copyMap[key];
      if (!data) return;
      trigger.setAttribute("aria-expanded", "true");
      kicker.textContent = `${data.title} / 详情`;
      renderDrawerContent(content, data);
      drawer.hidden = false;
    });
  });

  close?.addEventListener("click", closeDrawer);
}

function setupRoleHoverDrawer() {
  const region = document.querySelector(".role-labels");
  const drawer = document.getElementById("roleDrawer");
  const content = document.getElementById("roleDrawerContent");
  const kicker = document.getElementById("roleDrawerKicker");
  const triggers = [...document.querySelectorAll(".role-trigger")];
  if (!region || !drawer || !content || !kicker) return;

  let hideTimer;
  const clearHide = () => window.clearTimeout(hideTimer);
  const closeDrawer = () => {
    drawer.hidden = true;
    triggers.forEach((trigger) => trigger.setAttribute("aria-expanded", "false"));
  };
  const scheduleClose = () => {
    clearHide();
    hideTimer = window.setTimeout(() => {
      if (!region.matches(":hover") && !drawer.matches(":hover")) closeDrawer();
    }, 120);
  };
  const openDrawer = (trigger) => {
    const data = roleCopy[trigger.dataset.role];
    if (!data) return;
    clearHide();
    triggers.forEach((item) => item.setAttribute("aria-expanded", item === trigger ? "true" : "false"));
    kicker.textContent = `${data.title} / 详情`;
    renderDrawerContent(content, data);
    drawer.hidden = false;
  };

  region.addEventListener("pointerover", (event) => {
    const trigger = event.target.closest(".role-trigger");
    if (!trigger || !region.contains(trigger)) return;
    if (event.relatedTarget && trigger.contains(event.relatedTarget)) return;
    openDrawer(trigger);
  });
  region.addEventListener("pointerleave", scheduleClose);
  drawer.addEventListener("pointerenter", clearHide);
  drawer.addEventListener("pointerleave", scheduleClose);
  triggers.forEach((trigger) => {
    trigger.addEventListener("focus", () => openDrawer(trigger));
    trigger.addEventListener("click", () => openDrawer(trigger));
  });
}

setupRoleHoverDrawer();

setupDrawer({
  triggerSelector: ".work-label",
  drawerId: "projectDrawer",
  contentId: "projectDrawerContent",
  kickerId: "projectDrawerKicker",
  copyMap: projectCopy
});

const worksBoard = document.getElementById("worksBoard");
const route = document.getElementById("worksRoutePath");
const routeNodes = [...document.querySelectorAll(".works-route-node")];

if (worksBoard && route) {
  const length = route.getTotalLength();
  route.style.strokeDasharray = length;
  route.style.strokeDashoffset = length;
  const routeObserver = new IntersectionObserver((entries, observer) => {
    if (!entries[0].isIntersecting) return;
    observer.disconnect();
    worksBoard.classList.add("is-route-complete");
    if (!reducedMotion) {
      worksBoard.querySelector(".works-route").classList.add("is-drawing");
      routeNodes.forEach((node, index) => {
        window.setTimeout(() => node.classList.add("is-hit"), 430 + index * 620);
      });
    } else {
      route.style.strokeDashoffset = 0;
      routeNodes.forEach((node) => node.classList.add("is-hit"));
    }
  }, { threshold: 0.14 });
  routeObserver.observe(worksBoard);
}

document.querySelector(".role-question")?.addEventListener("click", () => {
  document.getElementById("chat")?.scrollIntoView({ behavior: reducedMotion ? "auto" : "smooth" });
});

const fontToggle = document.getElementById("fontToggle");
const savedFont = window.localStorage?.getItem("runmeng-font");
if (savedFont === "sans" || savedFont === "songti") document.body.dataset.font = savedFont;
fontToggle?.addEventListener("click", () => {
  const next = document.body.dataset.font === "songti" ? "sans" : "songti";
  document.body.dataset.font = next;
  window.localStorage?.setItem("runmeng-font", next);
  fontToggle.textContent = next === "songti" ? "宋体 / Sans" : "Sans / 宋体";
});
