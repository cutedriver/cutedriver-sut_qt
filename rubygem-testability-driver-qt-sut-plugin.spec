# Generated from testability-driver-qt-sut-plugin-0.8.4.20100804164353.gem by gem2rpm -*- rpm-spec -*-
%define ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%define gemname testability-driver-qt-sut-plugin
%define geminstdir %{gemdir}/gems/%{gemname}-%{version}

Summary: Testability Driver - Testability Driver Interface Qt SUT plugin
Name: rubygem-%{gemname}
Version: 0.8.4.20100804164353
Release: 1%{?dist}
Group: Development/Languages
License: GPLv2+ or Ruby
URL: http://gitorious.org/tdriver
Source0: %{gemname}-%{version}.gem
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: rubygems
Requires: rubygem(testability-driver) >= 0.8.3
BuildArch: noarch
BuildRequires: rubygems rubygem-testability-driver rubygem-nokogiri 
Provides: rubygem(%{gemname}) = %{version}

%description
Testability Driver - Testability Driver Interface Qt SUT plugin


%prep

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{gemdir}
export TDRIVER_HOME=%{buildroot}/etc/tdriver
gem install --local --install-dir %{buildroot}%{gemdir} \
            --force --rdoc %{SOURCE0}

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root, -)
%{_sysconfdir}/tdriver/*
%{gemdir}/gems/%{gemname}-%{version}/
%doc %{gemdir}/doc/%{gemname}-%{version}
%{gemdir}/cache/%{gemname}-%{version}.gem
%{gemdir}/specifications/%{gemname}-%{version}.gemspec


%changelog
* Wed Aug 04 2010 Tatu Lahtela,,, <ext-tatu.lahtela@nokia.com> - 0.8.4.20100804164353-1
- Initial package
