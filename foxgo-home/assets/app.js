const STORAGE_KEY = 'foxgo_integration_v2';

const defaultIntegration = {
  baseUrl: window.location.origin,
  categoriesPath: '/api/v1/categories',
  storesPath: '/api/v1/stores/recommended',
  searchPath: '/api/v1/items/item-or-store-search',
  customerSubmitPath: '/api/v1/auth/sign-up',
  vendorSubmitPath: '/api/v1/auth/vendor/register',
};

const views = {
  home: 'tpl-home',
  explorar: 'tpl-categorias',
  categorias: 'tpl-categorias',
  lojas: 'tpl-lojas',
  mercado: 'tpl-lojas',
  farmacia: 'tpl-lojas',
  bebidas: 'tpl-lojas',
  pet: 'tpl-lojas',
  clientes: 'tpl-clientes',
  parceiros: 'tpl-parceiros',
  config: 'tpl-config',
};

const state = {
  integration: loadIntegration(),
  vendorStep: 1,
};

function loadIntegration() {
  try {
    return { ...defaultIntegration, ...JSON.parse(localStorage.getItem(STORAGE_KEY) || '{}') };
  } catch {
    return { ...defaultIntegration };
  }
}

function saveIntegration(data) {
  state.integration = { ...state.integration, ...data };
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state.integration));
}

function url(path) {
  return `${state.integration.baseUrl.replace(/\/$/, '')}${path}`;
}

function mountView() {
  const key = (location.hash.replace('#', '') || 'home').toLowerCase();
  const templateId = views[key] || views.home;
  const template = document.getElementById(templateId);
  const view = document.getElementById('view');

  view.innerHTML = '';
  view.append(template.content.cloneNode(true));

  bindHomeActions();
  bindCategoriesActions();
  bindStoresActions();
  bindCustomerForm();
  bindVendorForm();
  bindIntegrationForm();
}

function createCard(title, subtitle) {
  const card = document.createElement('article');
  card.innerHTML = `<h3>${title}</h3><p>${subtitle || ''}</p>`;
  return card;
}

async function fetchJson(path) {
  const response = await fetch(url(path), { headers: { Accept: 'application/json' } });
  const data = await response.json();
  if (!response.ok) throw new Error(data?.message || 'Erro de integração');
  return data;
}

function bindHomeActions() {
  const btn = document.getElementById('run-search');
  const input = document.getElementById('global-search');
  if (!btn || !input) return;

  btn.addEventListener('click', async () => {
    const term = input.value.trim();
    if (!term) return;
    location.hash = '#lojas';
    setTimeout(async () => {
      const grid = document.getElementById('stores-grid');
      if (!grid) return;

      grid.innerHTML = '';
      try {
        const res = await fetchJson(`${state.integration.searchPath}?name=${encodeURIComponent(term)}`);
        const list = res?.data || res?.stores || [];
        if (!list.length) {
          grid.append(createCard('Nenhum resultado', 'Tente outro termo.'));
          return;
        }
        list.slice(0, 12).forEach((item) => {
          grid.append(createCard(item?.name || item?.item_name || 'Resultado', item?.slug || item?.store_name));
        });
      } catch (error) {
        grid.append(createCard('Erro na busca', error.message));
      }
    }, 30);
  });
}

function bindCategoriesActions() {
  const grid = document.getElementById('categories-grid');
  const reload = document.getElementById('reload-categories');
  if (!grid || !reload) return;

  const load = async () => {
    grid.innerHTML = '';
    try {
      const res = await fetchJson(state.integration.categoriesPath);
      const categories = res?.data || res || [];
      categories.slice(0, 16).forEach((category) => {
        grid.append(createCard(category?.name || 'Categoria', category?.slug || `ID ${category?.id ?? '-'}`));
      });
      if (!categories.length) grid.append(createCard('Sem dados', 'Nenhuma categoria recebida.'));
    } catch (error) {
      grid.append(createCard('Erro ao carregar categorias', error.message));
    }
  };

  reload.addEventListener('click', load);
  load();
}

function bindStoresActions() {
  const grid = document.getElementById('stores-grid');
  const reload = document.getElementById('reload-stores');
  if (!grid || !reload) return;

  const load = async () => {
    grid.innerHTML = '';
    try {
      const res = await fetchJson(state.integration.storesPath);
      const stores = res?.stores || res?.data || res || [];
      stores.slice(0, 16).forEach((store) => {
        grid.append(createCard(store?.name || 'Loja', `Entrega: ${store?.delivery_time || '-'}`));
      });
      if (!stores.length) grid.append(createCard('Sem dados', 'Nenhuma loja recebida.'));
    } catch (error) {
      grid.append(createCard('Erro ao carregar lojas', error.message));
    }
  };

  reload.addEventListener('click', load);
  load();
}

function bindCustomerForm() {
  const form = document.getElementById('customer-form');
  const out = document.getElementById('customer-response');
  if (!form || !out) return;

  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    out.textContent = 'Enviando...';

    try {
      const payload = Object.fromEntries(new FormData(form).entries());
      const response = await fetch(url(state.integration.customerSubmitPath), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
        body: JSON.stringify(payload),
      });
      const data = await response.json();
      out.textContent = JSON.stringify({ status: response.status, data }, null, 2);
    } catch (error) {
      out.textContent = JSON.stringify({ error: error.message }, null, 2);
    }
  });
}

function setVendorStep(step) {
  state.vendorStep = step;
  const sections = [...document.querySelectorAll('.v-step')];
  const tabs = [...document.querySelectorAll('#vendor-steps li')];
  const prev = document.getElementById('v-prev');
  const next = document.getElementById('v-next');
  const submit = document.getElementById('v-submit');

  sections.forEach((section) => section.classList.toggle('active', Number(section.dataset.step) === step));
  tabs.forEach((tab) => tab.classList.toggle('active', Number(tab.dataset.step) === step));

  prev?.classList.toggle('hidden', step === 1);
  next?.classList.toggle('hidden', step === sections.length);
  submit?.classList.toggle('hidden', step !== sections.length);
}

function validateVendorStep() {
  const section = document.querySelector(`.v-step[data-step="${state.vendorStep}"]`);
  if (!section) return true;

  const invalid = [...section.querySelectorAll('input[required]')].find((input) => !input.value);
  if (invalid) {
    invalid.focus();
    return false;
  }
  return true;
}

function buildVendorPayload(formData) {
  const payload = new FormData();

  payload.append('f_name', formData.get('owner_name') || '');
  payload.append('email', formData.get('owner_email') || '');
  payload.append('phone', formData.get('owner_phone') || '');
  payload.append('password', formData.get('owner_password') || '');
  payload.append('latitude', formData.get('latitude') || '');
  payload.append('longitude', formData.get('longitude') || '');
  payload.append('minimum_delivery_time', '30');
  payload.append('maximum_delivery_time', '45');
  payload.append('delivery_time_type', 'min');
  payload.append('zone_id', '1');
  payload.append('module_id', '1');

  payload.append('translations', JSON.stringify([
    { locale: 'en', key: 'name', value: String(formData.get('store_name') || '') },
    { locale: 'en', key: 'address', value: String(formData.get('store_address') || '') },
  ]));

  if (formData.get('logo')) payload.append('logo', formData.get('logo'));
  if (formData.get('cover')) payload.append('cover_photo', formData.get('cover'));

  return payload;
}

function bindVendorForm() {
  const form = document.getElementById('vendor-form');
  const out = document.getElementById('vendor-response');
  const prev = document.getElementById('v-prev');
  const next = document.getElementById('v-next');
  if (!form || !out || !prev || !next) return;

  setVendorStep(1);

  prev.addEventListener('click', () => setVendorStep(Math.max(state.vendorStep - 1, 1)));
  next.addEventListener('click', () => {
    if (!validateVendorStep()) return;
    setVendorStep(Math.min(state.vendorStep + 1, 4));
  });

  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    if (!validateVendorStep()) return;

    out.textContent = 'Enviando loja...';

    try {
      const response = await fetch(url(state.integration.vendorSubmitPath), {
        method: 'POST',
        headers: { Accept: 'application/json' },
        body: buildVendorPayload(new FormData(form)),
      });

      const data = await response.json();
      out.textContent = JSON.stringify({ status: response.status, data }, null, 2);
    } catch (error) {
      out.textContent = JSON.stringify({ error: error.message }, null, 2);
    }
  });
}

function bindIntegrationForm() {
  const form = document.getElementById('integration-form');
  const status = document.getElementById('integration-status');
  if (!form || !status) return;

  Object.entries(state.integration).forEach(([key, value]) => {
    const input = form.querySelector(`[name="${key}"]`);
    if (input) input.value = value;
  });

  status.textContent = JSON.stringify(state.integration, null, 2);

  form.addEventListener('submit', (event) => {
    event.preventDefault();
    saveIntegration(Object.fromEntries(new FormData(form).entries()));
    status.textContent = JSON.stringify({ saved: true, integration: state.integration }, null, 2);
  });
}

function renderRoutesDebugBox() {
  const routesList = document.getElementById('routes-list');
  if (!routesList) return;

  routesList.innerHTML = '';
  const ul = document.createElement('ul');
  Object.entries(state.integration).forEach(([key, value]) => {
    const li = document.createElement('li');
    li.innerHTML = `<strong>${key}</strong>: <code>${value}</code>`;
    ul.append(li);
  });
  routesList.append(ul);
}

window.addEventListener('hashchange', () => {
  mountView();
  renderRoutesDebugBox();
});

mountView();
renderRoutesDebugBox();
