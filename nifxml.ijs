NB. extract raw nif structure definition

nifxml=:3 :0
  if. fexist 'nif.xml' do.
    fread 'nif.xml'
  else.
    require'web/gethttp'
    nif=. gethttp'https://raw.githubusercontent.com/niftools/nifxml/develop/nif.xml'
    if. '<'={.nif do.
      nif fwrite 'nif.xml'
    end.
    nif
  end.
)

parsenif=:3 :0
  raw=:nifxml''
  edges=:I.'<'=raw  NB. only used for parsing the xml (assumes no quoted < chars)
  versions=: {:"1;getall 'version'
  getall each;:'bitflags enum basic compound niobject'
)

Note'attributes'
  version:  num
  bitflags: name storage
  enum:     name storage ver1
  basic:    name count niflibtype nifskopetype istemplate
  compound: name niflibtype nifskopetype istemplate ver1
  niobject: name abstract inherit
)

Note'secondary attributes'
  version:
  bitflags: value name
  enum: value name
  basic:
  compound: name type arr1 ver2 ver1 arr2 template default vercond cond arg calculated userver
  niobject: name type arr1 template arr2 arr3 cond ver1 default vercond ver2 calculated nifskopetype userver  ver userver2 arg abstract
)

extract=:4 :0
  locs=.I.('<',x) E. y
  xedge=. I.'<'=y
  lens=. ((xedge I.locs+1) { xedge)-locs
  r=. i.0
  for_l.locs do.
    txt=.(l+i.l_index{lens){y
    el=. (1+1 i.~ (txt='>')>~:/\txt='"'){.txt
    assert. (_2{el-.' ') e.'/"'
    assert.('"'+/ .=el)=2*+/'="' E.el
    r=.r,<attributes el
  end.
)

options=:3 :0
  seq=. 'option' extract y
  NB. name/value pairs
  {:"1@/:~@> seq
)

adds=:3 :0
  seq=: 'add' extract y
  NB. named freeform
  >((((<@,1:)@] {:: [)(;<)(<@<@<@] { [)) i.&(<'name')@:({."1))each seq
)

check=:3 :0
  assert.-.'"' e.;,y
  y
)

attributes=:3 :0
  t=. (}.~ [:-'/'={:) ' ',}:y
  segs=. (#~ '='&e.@>) }.t <;._1~(' '&= * 0=[: ~:/\ '"'&=)t
  split=. i.&'='@>segs
  check (split{.&.> segs),. (2+split) (_1 }. }.)&.> segs
)

getall=:3 :0
  type=.'type';y
  locs=.I.('<',y) E. raw
  lens=. ((edges I.locs+1) { edges)-locs
  ends=. ({~ I.&locs) I.('</',y) E. raw
  elen=. (#'</',y,'>')+((ends I.locs) { ends) - locs
  r=.''
  for_l.locs do.
    txt=.(l+i.l_index{lens){raw
    el=. (1+txt i.'>'){.txt
    assert.('"'+/ .=el)=2*+/'="' E.el
    e=. a=. (attributes el),type
    if. -.'/'=_2{el do.
      assert. '"'=_2{el
      full=. (l+i.l_index{elen){raw
      if. 'basic'-:y do. e=. a
      elseif.'version'-:y do. e=. a
      elseif. 'bitflags'-:y do.
        e=. a,options full
      elseif. 'enum'-:y do.
        e=. a,options full
      elseif. 1 do.
        e=. a,adds full
      end.
    end.
    r=.r,<e
  end.
)

primitivetypes=:3 :0
  /:~~.{:"1(#~ (<'storage')={."1);;parsenif''
)

referencedtypes=:3 :0
  /:~~.{:"1(#~ (<'type')={."1);(#~ 2=L."0) {:"1;; parsenif''
)

namedtypes=:3 :0
  /:~~.{:"1 (#~ (<'name')={."1);; parsenif''
)

NB. TEMPLATE types will need hardcoded support
