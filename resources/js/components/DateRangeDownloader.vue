<template>
  <div class="date-range-downloader">
    <button class="btn btn-sm btn-secondary" @click="showPopup = !showPopup">
      <i class="fas fa-download"></i> {{ i18n.t('descargar') }}
    </button>
    <div v-if="showPopup" class="download-popup">
      <div class="popup-header">
        <strong>{{ i18n.t('descargar_rango_fechas') }}</strong>
        <button class="btn btn-sm btn-ghost" @click="showPopup = false"><i class="fas fa-times"></i></button>
      </div>
      <div class="form-group">
        <label>{{ i18n.t('desde') }}</label>
        <input v-model="fechaDesde" type="date" class="form-control">
      </div>
      <div class="form-group">
        <label>{{ i18n.t('hasta') }}</label>
        <input v-model="fechaHasta" type="date" class="form-control">
      </div>
      <div class="popup-actions">
        <button class="btn btn-sm btn-primary" @click="descargarCSV" :disabled="isDownloading">
          <i v-if="isDownloading" class="fas fa-spinner fa-spin"></i>
          <i v-else class="fas fa-file-csv"></i> CSV
        </button>
        <button class="btn btn-sm btn-primary" @click="descargarPDF" :disabled="isDownloading">
          <i v-if="isDownloading" class="fas fa-spinner fa-spin"></i>
          <i v-else class="fas fa-file-pdf"></i> PDF
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useI18nStore } from '../stores/i18n';
import { useToastStore } from '../stores/toast';

const i18n = useI18nStore();
const toast = useToastStore();

const props = defineProps({
  fetchData: { type: Function, required: true },
  filename: { type: String, default: 'export' },
  columns: { type: Array, required: true },
});

const showPopup = ref(false);
const isDownloading = ref(false);
const fechaDesde = ref(new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0]);
const fechaHasta = ref(new Date().toISOString().split('T')[0]);

async function fetchDataInRange() {
  return await props.fetchData(fechaDesde.value, fechaHasta.value);
}

function generateCSV(data) {
  const headers = props.columns.map(c => c.label).join(',');
  const rows = data.map(row => props.columns.map(c => {
    let val = row[c.key] ?? '';
    val = String(val).replace(/"/g, '""');
    return `"${val}"`;
  }).join(','));
  return [headers, ...rows].join('\n');
}

function downloadFile(content, filename, mimeType) {
  const blob = new Blob(['\ufeff' + content], { type: mimeType });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

async function descargarCSV() {
  isDownloading.value = true;
  try {
    const data = await fetchDataInRange();
    const csv = generateCSV(data);
    downloadFile(csv, `${props.filename}_${fechaDesde.value}_${fechaHasta.value}.csv`, 'text/csv;charset=utf-8;');
    toast.success(i18n.t('descarga_exitosa'));
    showPopup.value = false;
  } catch (e) {
    toast.error(i18n.t('error_descarga'));
  }
  isDownloading.value = false;
}

function generatePDFContent(data) {
  const headerRow = props.columns.map(c => `<th style="padding:8px;background:#0f172a;color:#fff;font-size:11px;text-transform:uppercase;">${c.label}</th>`).join('');
  const bodyRows = data.map(row => '<tr>' + props.columns.map(c => `<td style="padding:8px;border-bottom:1px solid #e2e8f0;font-size:13px;">${row[c.key] ?? '-'}</td>`).join('') + '</tr>').join('');

  return `<!DOCTYPE html><html><head><meta charset="utf-8"><style>
    body{font-family:Arial,sans-serif;padding:20px;color:#1e293b;}
    h1{font-size:18px;margin-bottom:4px;}
    .date-range{font-size:12px;color:#64748b;margin-bottom:16px;}
    table{width:100%;border-collapse:collapse;}
    th{background:#0f172a;color:#fff;padding:8px;font-size:11px;text-transform:uppercase;}
    td{padding:8px;border-bottom:1px solid #e2e8f0;font-size:13px;}
    @media print{body{padding:0;}}
  </style></head><body>
    <h1>${props.filename}</h1>
    <div class="date-range">${fechaDesde.value} - ${fechaHasta.value}</div>
    <table><thead><tr>${headerRow}</tr></thead><tbody>${bodyRows}</tbody></table>
  </body></html>`;
}

async function descargarPDF() {
  isDownloading.value = true;
  try {
    const data = await fetchDataInRange();
    const html = generatePDFContent(data);
    const w = window.open('', '_blank');
    w.document.write(html);
    w.document.close();
    setTimeout(() => w.print(), 500);
    toast.success(i18n.t('descarga_exitosa'));
    showPopup.value = false;
  } catch (e) {
    toast.error(i18n.t('error_descarga'));
  }
  isDownloading.value = false;
}
</script>

<style scoped>
.date-range-downloader { position: relative; display: inline-block; }
.download-popup {
  position: absolute; top: 100%; right: 0; z-index: 100;
  background: var(--bg-card); border: 1px solid var(--bg-hover);
  border-radius: 12px; padding: 16px; min-width: 260px;
  box-shadow: 0 8px 24px rgba(0,0,0,0.12);
}
.popup-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.popup-header strong { font-size: 14px; }
.form-group { margin-bottom: 10px; }
.form-group label { display: block; font-size: 12px; font-weight: 600; margin-bottom: 4px; color: var(--text-muted); }
.form-control { width: 100%; padding: 8px; border: 1px solid var(--bg-hover); border-radius: 6px; font-size: 13px; }
.popup-actions { display: flex; gap: 8px; margin-top: 12px; }
.popup-actions .btn { flex: 1; }
</style>
