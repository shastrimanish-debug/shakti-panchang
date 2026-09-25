class AstrologerBranding {
  final String name;
  final String title;
  final String phone;
  final String city;
  final String sansthan;
  final String specialization;
  final String email;

  const AstrologerBranding({
    this.name = '',
    this.title = 'ज्योतिषाचार्य',
    this.phone = '',
    this.city = '',
    this.sansthan = '',
    this.specialization = '',
    this.email = '',
  });

  bool get isConfigured => name.trim().isNotEmpty;

  String get displayLine {
    final parts = <String>[
      if (title.trim().isNotEmpty) title.trim(),
      if (name.trim().isNotEmpty) name.trim(),
    ];
    return parts.join(' ');
  }

  Map<String, String> toJson() => {
        'name': name,
        'title': title,
        'phone': phone,
        'city': city,
        'sansthan': sansthan,
        'specialization': specialization,
        'email': email,
      };

  factory AstrologerBranding.fromJson(Map<String, dynamic> json) {
    String s(String k) => '${json[k] ?? ''}';
    return AstrologerBranding(
      name: s('name'),
      title: s('title').isEmpty ? 'ज्योतिषाचार्य' : s('title'),
      phone: s('phone'),
      city: s('city'),
      sansthan: s('sansthan'),
      specialization: s('specialization'),
      email: s('email'),
    );
  }
}
