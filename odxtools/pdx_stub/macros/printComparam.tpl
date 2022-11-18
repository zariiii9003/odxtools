{#- -*- mode: sgml; tab-width: 1; indent-tabs-mode: nil -*-
 #
 # SPDX-License-Identifier: MIT
 # Copyright (c) 2022 MBition GmbH
-#}

{# print either a simple or a complex comparam
 #}
{%- macro printGenericComparam(cp) %}
{#
 # This is slightly hacky: To distinguish complex and simple
 # communication parameters, we check if the 'cp' object has a
 # 'comparams' attribute. If it does, it is a complex parameter.
 #}
{%- if hasattr(cp, 'comparams') %}
{{- printComplexComparam(cp) }}
{%- else %}
{{- printSimpleComparam(cp) }}
{%- endif %}
{%- endmacro %}


{%- macro printSimpleComparam(cp) %}
<COMPARAM ID="{{cp.odx_id.local_id}}"
          PARAM-CLASS="{{cp.param_class}}"
          CPTYPE="{{cp.cptype}}"
          {%- if cp.display_level is not none %}
          DISPLAY-LEVEL="{{cp.display_level}}"
          {%- endif %}
          CPUSAGE="{{cp.cpusage}}">
 <SHORT-NAME>{{cp.short_name}}</SHORT-NAME>
 {%- if cp.long_name and cp.long_name.strip() %}
 <LONG-NAME>{{cp.long_name|e}}</LONG-NAME>
 {%- endif %}
 {%- if cp.description and cp.description.strip() %}
 <DESC>
 {{cp.description}}
 </DESC>
 {%- endif %}
 <PHYSICAL-DEFAULT-VALUE>{{cp.physical_default_value}}</PHYSICAL-DEFAULT-VALUE>
 <DATA-OBJECT-PROP-REF ID-REF="{{cp.dop_ref.ref_id}}" />
</COMPARAM>
{%- endmacro %}

{%- macro printComplexComparam(cp) %}
<COMPLEX-COMPARAM ID="{{cp.odx_id.local_id}}"
                  PARAM-CLASS="{{cp.param_class}}"
                  CPTYPE="{{cp.cptype}}"
                  {%- if cp.display_level is not none %}
                  DISPLAY-LEVEL="{{cp.display_level}}"
                  {%- endif %}
                  CPUSAGE="{{cp.cpusage}}"
                  {%- if cp.allow_multiple_values == True %}
                  ALLOW-MULTIPLE-VALUES="true"
                  {%- elif cp.allow_multiple_values == False %}
                  ALLOW-MULTIPLE-VALUES="false"
                  {%- endif %}
                  >
 <SHORT-NAME>{{cp.short_name}}</SHORT-NAME>
 {%- if cp.long_name and cp.long_name.strip() %}
 <LONG-NAME>{{cp.long_name|e}}</LONG-NAME>
 {%- endif %}
 {%- if cp.description and cp.description.strip() %}
 <DESC>
 {{cp.description}}
 </DESC>
 {%- endif %}
 {%- for sub_cp in cp.comparams %}
 {{- printGenericComparam(sub_cp) | indent(1, first=True) }}
 {%- endfor %}
 {%- if cp.physical_default_value is not none %}
 <COMPLEX-PHYSICAL-DEFAULT-VALUE>{{cp.physical_default_value}}</COMPLEX-PHYSICAL-DEFAULT-VALUE>
 {%- endif %}
</COMPLEX-COMPARAM>
{%- endmacro %}
