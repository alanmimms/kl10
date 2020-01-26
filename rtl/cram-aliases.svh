// CRAM field/subfield aliases
logic ADA_EN;
assign ADA_EN = CRAM.f.ADA[0];

logic ADbool;
assign ADbool = CRAM.f.AD[1];

logic [0:5] SPEC;
assign SPEC = CRAM.f.DISP;

logic [0:8] DIAG_FUNC;
assign DIAG_FUNC = CRAM.f.MAGIC;

logic [0:5] SKIP;
assign SKIP = CRAM.f.COND;
