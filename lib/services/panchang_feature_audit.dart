class PanchangFeatureAuditItem {
  const PanchangFeatureAuditItem(this.name, this.verified);
  final String name;
  final bool verified;
}

const panchangAdvancedFeatureAudit = <PanchangFeatureAuditItem>[
  PanchangFeatureAuditItem('KP astrology', false),
  PanchangFeatureAuditItem('Lal Kitab', false),
  PanchangFeatureAuditItem('Prashna / Horary', false),
  PanchangFeatureAuditItem('Tajik / Varshaphal depth', false),
  PanchangFeatureAuditItem('Additional Dasha systems', false),
  PanchangFeatureAuditItem('Advanced compatibility scoring', false),
  PanchangFeatureAuditItem('Chart-based prediction synthesis', false),
];
