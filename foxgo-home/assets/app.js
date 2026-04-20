const ROUTES = {
  modules: '/api/v1/module',
  categories: '/api/v1/categories',
  banners: '/api/v1/banners',
  recommendedStores: '/api/v1/stores/recommended',
  latestStores: '/api/v1/stores/latest',
  customerSignUp: '/api/v1/auth/sign-up',
  vendorRegister: '/api/v1/auth/vendor/register',
  webVendorApply: '/vendor/apply',
  webCustomerLogin: '/customer/auth/login',
};

const $ = (selector) => document.querySelector(selector);

const apiBaseInput = $('#api-base');
const saveApiBaseButton = $('#save-api-base');
const statusBox = $('#status-box');

const categoriesGrid = $('#categories-grid');
const storesGrid = $('#stores-grid');
const routesList = $('#routes-list');

const customerForm = $('#customer-form');
const customerResponseBox = $('#customer-response');

const vendorForm = $('#vendor-form');
const vendorResponseBox = $('#vendor-response');
const vendorPrevButton = $('#vendor-prev');
const vendorNextButton = $('#vendor-next');
const vendorSubmitButton = $('#vendor-submit');

const vendorSteps = [...document.querySelectorAll('.vendor-step')];
const stepDots = [...document.querySelectorAll('#vendor-stepper li')];

const reloadCategoriesButton = $('#reload-categories');
const reloadStoresButton = $('#reload-stores');

let currentVendorStep = 1;

function getApiBase() {
  return localStorage.getItem('foxgo_api_base') || window.location.origin;
}

function setApiBase(value) {
  localStorage.setItem('foxgo_api_base', value.replace(/\/$/, ''));
}

function fullUrl(path) {
  return `${getApiBase()}${path}`;
}

function printJson(target, payload) {
  target.textContent = JSON.stringify(payload, null, 2);
}

function createCard(title, description) {
  const article = document.createElement('article');
  article.innerHTML = `<h3>${title}</h3><p>${description}</p>`;
  return article;
}

async function fetchJson(path) {
  const response = await fetch(fullUrl(path), { headers: { Accept: 'application/json' } });
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data?.message || `Falha em ${path}`);
  }
  return data;
}

async function loadCategories() {
  categoriesGrid.innerHTML = '';
  try {
    const response = await fetchJson(ROUTES.categories);
    const categories = response?.data || response || [];

    categories.slice(0, 12).forEach((item) => {
      categoriesGrid.append(
        createCard(item?.name || 'Categoria', item?.slug || `ID ${item?.id ?? '-'}`)
      );
    });

    if (!categories.length) {
      categoriesGrid.append(createCard('Sem dados', 'A API não retornou categorias.'));
    }
  } catch (error) {
    categoriesGrid.append(createCard('Erro ao carregar categorias', error.message));
  }
}

async function loadStores() {
  storesGrid.innerHTML = '';
  try {
    const response = await fetchJson(ROUTES.recommendedStores);
    const stores = response?.stores || response?.data || response || [];

    stores.slice(0, 12).forEach((item) => {
      storesGrid.append(
        createCard(item?.name || 'Loja', `Entrega: ${item?.delivery_time || 'não informado'}`)
      );
    });

    if (!stores.length) {
      storesGrid.append(createCard('Sem dados', 'A API não retornou lojas.'));
    }
  } catch (error) {
    storesGrid.append(createCard('Erro ao carregar lojas', error.message));
  }
}

function renderRoutesList() {
  const ul = document.createElement('ul');
  Object.entries(ROUTES).forEach(([name, route]) => {
    const li = document.createElement('li');
    li.innerHTML = `<strong>${name}</strong>: <code>${route}</code>`;
    ul.append(li);
  });
  routesList.innerHTML = '';
  routesList.append(ul);
}

function setWizardStep(step) {
  currentVendorStep = step;

  vendorSteps.forEach((section) => {
    section.classList.toggle('active', Number(section.dataset.step) === step);
  });

  stepDots.forEach((dot) => {
    dot.classList.toggle('active', Number(dot.dataset.step) === step);
  });

  vendorPrevButton.classList.toggle('hidden', step === 1);
  vendorNextButton.classList.toggle('hidden', step === vendorSteps.length);
  vendorSubmitButton.classList.toggle('hidden', step !== vendorSteps.length);
}

function getRequiredInputsFromStep(step) {
  const section = vendorSteps.find((item) => Number(item.dataset.step) === step);
  if (!section) {
    return [];
  }

  return [...section.querySelectorAll('input[required]')];
}

function validateCurrentStep() {
  const requiredInputs = getRequiredInputsFromStep(currentVendorStep);
  const invalidInput = requiredInputs.find((input) => !input.value);

  if (invalidInput) {
    invalidInput.focus();
    vendorResponseBox.textContent = `Preencha o campo obrigatório: ${invalidInput.name}`;
    return false;
  }

  return true;
}

vendorNextButton.addEventListener('click', () => {
  if (!validateCurrentStep()) {
    return;
  }

  setWizardStep(Math.min(currentVendorStep + 1, vendorSteps.length));
});

vendorPrevButton.addEventListener('click', () => {
  setWizardStep(Math.max(currentVendorStep - 1, 1));
});

customerForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  customerResponseBox.textContent = 'Enviando cadastro de cliente...';

  try {
    const payload = Object.fromEntries(new FormData(customerForm).entries());
    const response = await fetch(fullUrl(ROUTES.customerSignUp), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
      body: JSON.stringify(payload),
    });

    const data = await response.json();
    printJson(customerResponseBox, { status: response.status, data });
  } catch (error) {
    printJson(customerResponseBox, { error: error.message });
  }
});

vendorForm.addEventListener('submit', async (event) => {
  event.preventDefault();

  if (!validateCurrentStep()) {
    return;
  }

  vendorResponseBox.textContent = 'Enviando cadastro de loja...';

  try {
    const formData = new FormData(vendorForm);

    const storeName = formData.get('store_name');
    const storeAddress = formData.get('store_address');
    formData.delete('store_name');
    formData.delete('store_address');

    const translations = [
      { locale: 'en', key: 'name', value: String(storeName || '') },
      { locale: 'en', key: 'address', value: String(storeAddress || '') },
    ];

    formData.set('translations', JSON.stringify(translations));

    const response = await fetch(fullUrl(ROUTES.vendorRegister), {
      method: 'POST',
      headers: { Accept: 'application/json' },
      body: formData,
    });

    const data = await response.json();
    printJson(vendorResponseBox, { status: response.status, data });
  } catch (error) {
    printJson(vendorResponseBox, { error: error.message });
  }
});

saveApiBaseButton.addEventListener('click', async () => {
  const value = apiBaseInput.value.trim();
  if (!value) {
    return;
  }

  setApiBase(value);
  statusBox.textContent = `Base configurada: ${getApiBase()}`;
  await Promise.allSettled([loadCategories(), loadStores()]);
});

reloadCategoriesButton.addEventListener('click', loadCategories);
reloadStoresButton.addEventListener('click', loadStores);

async function init() {
  apiBaseInput.value = getApiBase();
  statusBox.textContent = `Base atual: ${getApiBase()}`;

  renderRoutesList();
  setWizardStep(1);

  await Promise.allSettled([loadCategories(), loadStores()]);
}

init();
