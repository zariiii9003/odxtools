{#- -*- mode: sgml; tab-width: 1; indent-tabs-mode: nil -*-
 #
 # SPDX-License-Identifier: MIT
 # Copyright (c) 2022 MBition GmbH
-#}

{%- macro printMux(mux) %}
<MUX ID="{{mux.odx_id.local_id}}">
  <SHORT-NAME>{{mux.short_name}}</SHORT-NAME>
  <LONG-NAME>{{mux.long_name|e}}</LONG-NAME>
  <BYTE-POSITION>{{mux.byte_position}}</BYTE-POSITION>
  <SWITCH-KEY>
    <BYTE-POSITION>{{mux.switch_key.byte_position}}</BYTE-POSITION>
    {%- if mux.switch_key.bit_position is not none %}
    <BIT-POSITION>{{mux.switch_key.bit_position}}</BIT-POSITION>
    {%- endif %}
    <DATA-OBJECT-PROP-REF ID-REF="{{mux.switch_key.dop_ref.ref_id}}"/>
  </SWITCH-KEY>
  {%- if mux.default_case is not none %}
  <DEFAULT-CASE>
    <SHORT-NAME>{{mux.default_case.short_name}}</SHORT-NAME>
    <LONG-NAME>{{mux.default_case.long_name}}</LONG-NAME>
    {%- if mux.default_case.structure_ref is not none %}
    <STRUCTURE-REF ID-REF="{{mux.default_case.structure_ref.ref_id}}"/>
    {%- endif %}
  </DEFAULT-CASE>
  {%- endif %}
  <CASES>
    {%- for case in mux.cases %}
    <CASE>
      <SHORT-NAME>{{case.short_name}}</SHORT-NAME>
      <LONG-NAME>{{case.long_name}}</LONG-NAME>
      <STRUCTURE-REF ID-REF="{{case.structure_ref.ref_id}}"/>
      <LOWER-LIMIT>{{case.lower_limit}}</LOWER-LIMIT>
      <UPPER-LIMIT>{{case.upper_limit}}</UPPER-LIMIT>
    </CASE>
    {%- endfor %}
  </CASES>
</MUX>
{%- endmacro -%}
