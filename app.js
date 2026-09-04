const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

const entry = document.getElementById("entry");
const enterButton = document.getElementById("enterButton");
let hasEntered = false;

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

const revealObserver = typeof IntersectionObserver === "function" ? new IntersectionObserver((entries, observer) => {
  entries.forEach((entryItem) => {
    if (!entryItem.isIntersecting) return;
    entryItem.target.classList.add("is-visible");
    observer.unobserve(entryItem.target);
  });
}, { threshold: 0.12 }) : null;

document.querySelectorAll(".reveal").forEach((element) => {
  if (revealObserver) revealObserver.observe(element);
  else element.classList.add("is-visible");
});

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

function setupHeroInteraction() {
  const panel = document.querySelector(".hero-panel");
  if (!panel || reducedMotion) return;

  panel.addEventListener("pointermove", (event) => {
    const rect = panel.getBoundingClientRect();
    panel.style.setProperty("--hero-offset-x", `${(((event.clientX - rect.left) / rect.width) - 0.5) * 7}px`);
    panel.style.setProperty("--hero-offset-y", `${(((event.clientY - rect.top) / rect.height) - 0.5) * 7}px`);
    panel.dataset.heroState = "attending";
  });
  panel.addEventListener("pointerleave", () => {
    panel.style.setProperty("--hero-offset-x", "0px");
    panel.style.setProperty("--hero-offset-y", "0px");
    panel.dataset.heroState = "idle";
  });
}

function setupRoleHoverDrawer() {
  const region = document.querySelector(".role-labels");
  const drawer = document.getElementById("roleDrawer");
  const content = document.getElementById("roleDrawerContent");
  const kicker = document.getElementById("roleDrawerKicker");
  const section = document.querySelector(".role-overview");
  const triggers = [...document.querySelectorAll(".role-trigger")];
  const labels = [...document.querySelectorAll(".role-label")];
  if (!region || !drawer || !content || !kicker || !section) return;

  let hideTimer;
  let lockedTrigger = null;
  const clearHide = () => window.clearTimeout(hideTimer);
  const setFocus = (trigger) => {
    section.dataset.roleFocus = trigger?.dataset.role || "";
    labels.forEach((label) => label.classList.toggle("is-focus", label.contains(trigger)));
  };
  const closeDrawer = ({ unlock = true } = {}) => {
    drawer.hidden = true;
    drawer.dataset.state = "closed";
    triggers.forEach((trigger) => trigger.setAttribute("aria-expanded", "false"));
    labels.forEach((label) => label.classList.remove("is-focus", "is-locked"));
    if (unlock) lockedTrigger = null;
    if (!lockedTrigger) delete section.dataset.roleFocus;
  };
  const scheduleClose = () => {
    clearHide();
    if (lockedTrigger) return;
    hideTimer = window.setTimeout(() => {
      if (!region.matches(":hover") && !drawer.matches(":hover")) closeDrawer({ unlock: false });
    }, 160);
  };
  const openDrawer = (trigger, { lock = false } = {}) => {
    const data = roleCopy[trigger.dataset.role];
    if (!data) return;
    clearHide();
    setFocus(trigger);
    drawer.style.gridColumn = String(triggers.indexOf(trigger) + 1);
    drawer.style.gridRow = "2";
    triggers.forEach((item) => item.setAttribute("aria-expanded", item === trigger ? "true" : "false"));
    labels.forEach((label) => label.classList.toggle("is-locked", lock && label.contains(trigger)));
    kicker.textContent = `${data.title} / 详情`;
    renderDrawerContent(content, data);
    drawer.hidden = false;
    drawer.dataset.state = lock ? "locked" : "preview";
    if (lock) lockedTrigger = trigger;
  };

  region.addEventListener("pointerover", (event) => {
    const trigger = event.target.closest(".role-trigger");
    if (!trigger || !region.contains(trigger)) return;
    if (lockedTrigger) return;
    if (event.relatedTarget && trigger.contains(event.relatedTarget)) return;
    openDrawer(trigger);
  });
  region.addEventListener("pointerleave", scheduleClose);
  drawer.addEventListener("pointerenter", clearHide);
  drawer.addEventListener("pointerleave", scheduleClose);
  triggers.forEach((trigger) => {
    trigger.addEventListener("focus", () => {
      if (!lockedTrigger) openDrawer(trigger);
    });
    trigger.addEventListener("click", () => {
      if (lockedTrigger === trigger) {
        closeDrawer();
        return;
      }
      openDrawer(trigger, { lock: true });
    });
  });
  drawer.querySelector(".drawer-close")?.addEventListener("click", () => closeDrawer());
}

setupRoleHoverDrawer();
setupHeroInteraction();

function setupRoleArtworkFlow() {
  const section = document.querySelector(".role-overview");
  const artwork = document.querySelector(".role-artwork-flow");
  if (!section || !artwork) return;

  const start = () => section.classList.add("is-role-flow-started");
  if (reducedMotion) {
    start();
    return;
  }

  const observer = new IntersectionObserver((entries, instance) => {
    if (!entries[0].isIntersecting) return;
    start();
    instance.disconnect();
  }, { threshold: 0.2 });
  observer.observe(section);
}

setupRoleArtworkFlow();

function setupExperienceRail() {
  const rail = document.querySelector("[data-experience-rail]");
  const previous = document.querySelector("[data-experience-prev]");
  const next = document.querySelector("[data-experience-next]");
  if (!rail || !previous || !next) return;

  const getStep = () => {
    const card = rail.querySelector(".experience-card");
    const styles = window.getComputedStyle(rail);
    return (card?.getBoundingClientRect().width || rail.clientWidth) + (parseFloat(styles.columnGap) || 0);
  };

  const updateControls = () => {
    const maxScroll = Math.max(0, rail.scrollWidth - rail.clientWidth);
    previous.disabled = rail.scrollLeft <= 4;
    next.disabled = rail.scrollLeft >= maxScroll - 4;
  };

  previous.addEventListener("click", () => {
    rail.scrollBy({ left: -getStep(), behavior: reducedMotion ? "auto" : "smooth" });
  });

  next.addEventListener("click", () => {
    rail.scrollBy({ left: getStep(), behavior: reducedMotion ? "auto" : "smooth" });
  });

  rail.addEventListener("scroll", updateControls, { passive: true });
  window.addEventListener("resize", updateControls, { passive: true });
  updateControls();
}

setupExperienceRail();

function setupAboutFocus() {
  const section = document.querySelector(".about");
  const items = [...document.querySelectorAll(".focus-list [data-about-key]")];
  const phrases = [...document.querySelectorAll(".about-phrase[data-about-phrase]")];
  const guideDot = document.querySelector("[data-about-guide-dot]");
  const guideWrap = document.querySelector(".focus-list-wrap");
  if (!section || !items.length || !phrases.length || !guideDot || !guideWrap) return;

  let lockedKey = null;
  let guideTimer;
  const moveGuideDot = (item, { immediate = false } = {}) => {
    const anchor = item.querySelector(".focus-dot");
    if (!anchor) return;
    const wrapRect = guideWrap.getBoundingClientRect();
    const anchorRect = anchor.getBoundingClientRect();
    const x = anchorRect.left - wrapRect.left;
    const y = anchorRect.top - wrapRect.top;
    guideDot.style.setProperty("--about-guide-x", `${x}px`);
    guideDot.style.setProperty("--about-guide-y", `${y}px`);
    guideDot.classList.toggle("is-immediate", immediate);
    guideDot.classList.add("is-visible");
    window.clearTimeout(guideTimer);
    guideTimer = window.setTimeout(() => guideDot.classList.remove("is-immediate"), 620);
  };
  const setFocus = (key) => {
    section.dataset.aboutFocus = key || "";
    items.forEach((item) => {
      const isFocus = item.dataset.aboutKey === key;
      item.classList.toggle("is-focus", isFocus);
      if (isFocus) moveGuideDot(item);
    });
    phrases.forEach((phrase) => phrase.classList.toggle("is-focus", phrase.dataset.aboutPhrase === key));
  };
  const clearFocus = () => {
    if (lockedKey) return;
    delete section.dataset.aboutFocus;
    items.forEach((item) => item.classList.remove("is-focus"));
    phrases.forEach((phrase) => phrase.classList.remove("is-focus"));
    moveGuideDot(items[0]);
  };

  moveGuideDot(items[0], { immediate: true });

  items.forEach((item) => {
    item.addEventListener("pointerenter", () => { if (!lockedKey) setFocus(item.dataset.aboutKey); });
    item.addEventListener("focus", () => { if (!lockedKey) setFocus(item.dataset.aboutKey); });
    item.addEventListener("pointerleave", clearFocus);
    item.addEventListener("blur", clearFocus);
    item.addEventListener("click", () => {
      const key = item.dataset.aboutKey;
      lockedKey = lockedKey === key ? null : key;
      if (lockedKey) setFocus(lockedKey);
      else clearFocus();
    });
    item.addEventListener("keydown", (event) => {
      if (event.key !== "Enter" && event.key !== " ") return;
      event.preventDefault();
      item.click();
    });
  });
}

setupAboutFocus();

setupDrawer({
  triggerSelector: ".work-label",
  drawerId: "projectDrawer",
  contentId: "projectDrawerContent",
  kickerId: "projectDrawerKicker",
  copyMap: projectCopy
});

function setupWorksInteractions() {
  const stage = document.querySelector("[data-works-stage]");
  const paths = [...document.querySelectorAll(".works-route-segment")];
  const nodes = [...document.querySelectorAll(".works-route-node")];
  const projects = [...document.querySelectorAll(".works-project[data-project]")];
  const dot = document.querySelector("[data-works-guide-dot]");
  if (!stage || !paths.length || !projects.length || !dot) return;

  const pathsByProject = new Map(paths.map((path) => [path.dataset.project, path]));
  let guideFrame = null;
  let guideToken = 0;
  let activeProject = null;

  paths.forEach((path, index) => {
    const length = path.getTotalLength();
    path.style.strokeDasharray = "1";
    path.style.strokeDashoffset = reducedMotion ? "0" : "1";
    path.style.setProperty("--route-delay", `${index * 520}ms`);
    path.dataset.length = String(length);
  });

  const pointAt = (path, progress) => path.getPointAtLength(Number(path.dataset.length) * progress);
  const placeDot = (path, progress) => {
    const point = pointAt(path, progress);
    dot.setAttribute("cx", point.x.toFixed(2));
    dot.setAttribute("cy", point.y.toFixed(2));
  };
  const animateDot = (path, from, to, duration = 560) => {
    guideToken += 1;
    const token = guideToken;
    if (guideFrame) cancelAnimationFrame(guideFrame);
    const started = performance.now();
    const tick = (now) => {
      if (token !== guideToken) return;
      const progress = Math.min(1, (now - started) / duration);
      const eased = 1 - Math.pow(1 - progress, 3);
      placeDot(path, from + (to - from) * eased);
      if (progress < 1 && !reducedMotion) guideFrame = requestAnimationFrame(tick);
    };
    if (reducedMotion) placeDot(path, to);
    else guideFrame = requestAnimationFrame(tick);
  };

  const setActiveProject = (project, { moving = true } = {}) => {
    activeProject = project;
    stage.dataset.activeProject = project || "";
    stage.classList.add("has-active-project");
    paths.forEach((path) => path.classList.toggle("is-active", path.dataset.project === project));
    nodes.forEach((node) => node.classList.toggle("is-active", node.dataset.project === project));
    projects.forEach((card) => card.classList.toggle("is-active", card.dataset.project === project));
    const path = pathsByProject.get(project);
    if (path) {
      dot.classList.add("is-visible");
      if (moving) animateDot(path, 0.08, 0.94);
      else placeDot(path, 0.94);
    }
  };

  const clearActiveProject = (card) => {
    if (document.activeElement === card || activeProject !== card.dataset.project) return;
    activeProject = null;
    stage.dataset.activeProject = "";
    stage.classList.remove("has-active-project");
    paths.forEach((path) => path.classList.remove("is-active"));
    nodes.forEach((node) => node.classList.remove("is-active"));
    projects.forEach((item) => item.classList.remove("is-active"));
    dot.classList.remove("is-visible");
    const lastPath = paths[paths.length - 1];
    if (lastPath) animateDot(lastPath, 0.9, 1, 360);
  };

  projects.forEach((card) => {
    card.addEventListener("pointerenter", () => setActiveProject(card.dataset.project));
    card.addEventListener("pointerleave", () => clearActiveProject(card));
    card.addEventListener("focus", () => setActiveProject(card.dataset.project, { moving: false }));
    card.addEventListener("blur", () => clearActiveProject(card));
  });

  const observer = new IntersectionObserver((entries, instance) => {
    if (!entries[0].isIntersecting) return;
    instance.disconnect();
    stage.classList.add("is-route-started");
    if (reducedMotion) {
      stage.classList.add("is-route-complete");
      paths.forEach((path) => { path.style.strokeDashoffset = "0"; });
      dot.classList.add("is-visible");
      placeDot(paths[paths.length - 1], 1);
      return;
    }
    window.setTimeout(() => {
      stage.classList.add("is-route-complete");
      dot.classList.add("is-visible");
      placeDot(paths[paths.length - 1], 1);
    }, 4900);
  }, { threshold: 0.2 });
  observer.observe(stage);
}

setupWorksInteractions();

document.querySelector(".role-question")?.addEventListener("click", () => {
  document.getElementById("chat")?.scrollIntoView({ behavior: reducedMotion ? "auto" : "smooth" });
});

const twinInput = document.querySelector(".twin-input");
document.querySelectorAll(".twin-guide-row").forEach((row) => {
  row.addEventListener("click", () => {
    if (!twinInput) return;
    document.querySelectorAll(".twin-guide-row").forEach((option) => {
      const isSelected = option === row;
      option.classList.toggle("is-selected", isSelected);
      option.setAttribute("aria-pressed", String(isSelected));
    });
    twinInput.value = row.dataset.prompt || "";
    twinInput.focus({ preventScroll: true });
  });
});

const twinChatForm = document.getElementById("twinChatForm");
const twinMessages = document.getElementById("twinMessages");
const twinStatus = document.getElementById("twinStatus");
const twinSend = document.getElementById("twinSend");
const twinChatEndpoint = window.PREVIEW_CHAT_ENDPOINT || window.PORTFOLIO_CHAT_ENDPOINT || "/api/chat";
const twinChatHistory = [];
let twinReplyCount = 0;
const twinReplyLimit = 8;

function addTwinMessage(text, role = "assistant", extra = "") {
  if (!twinMessages) return null;
  const message = document.createElement("p");
  message.className = `twin-chat-message ${role} ${extra}`.trim();
  message.textContent = text;
  twinMessages.appendChild(message);
  twinMessages.scrollTop = twinMessages.scrollHeight;
  return message;
}

twinChatForm?.addEventListener("submit", async (event) => {
  event.preventDefault();
  const message = twinInput?.value.trim();
  if (!message || !twinMessages || !twinSend || twinReplyCount >= twinReplyLimit) return;

  addTwinMessage(message, "user");
  twinChatHistory.push({ role: "user", content: message });
  twinInput.value = "";
  twinSend.disabled = true;
  if (twinStatus) twinStatus.textContent = "连接中…";
  const loading = addTwinMessage("正在想想…", "assistant", "loading");

  try {
    const response = await fetch(twinChatEndpoint, {
      method: "POST",
      headers: { "Content-Type": "application/json", Accept: "application/json" },
      body: JSON.stringify({ messages: twinChatHistory })
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(data.error || `HTTP ${response.status}`);
    loading?.remove();
    const reply = typeof data.reply === "string" ? data.reply : "我暂时没有拿到有效回答。";
    addTwinMessage(reply, "assistant");
    twinChatHistory.push({ role: "assistant", content: reply });
    twinReplyCount += 1;
    if (twinStatus) twinStatus.textContent = twinReplyCount >= twinReplyLimit ? "本次已聊完" : "已连接";
  } catch (error) {
    loading?.remove();
    addTwinMessage("安全服务尚未连接，请稍后再试。", "assistant", "error");
    twinInput.value = message;
    if (twinStatus) twinStatus.textContent = "未连接";
  } finally {
    twinSend.disabled = false;
    if (twinReplyCount >= twinReplyLimit) twinSend.disabled = true;
    twinInput?.focus({ preventScroll: true });
  }
});

/* Ending copy stays static. The cobalt route is the only element that moves. */
const endingScene = document.querySelector(".ending-scene");

if (endingScene) {
  const revealEndingLine = () => endingScene.classList.add("is-line-visible");

  if (reducedMotion || typeof IntersectionObserver !== "function") {
    revealEndingLine();
  } else {
    const endingObserver = new IntersectionObserver(([entry], observer) => {
      if (!entry.isIntersecting || entry.intersectionRatio < 0.35) return;
      revealEndingLine();
      observer.unobserve(endingScene);
    }, { threshold: [0.35] });

    endingObserver.observe(endingScene);
  }
}
