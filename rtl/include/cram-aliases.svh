// CRAM field/subfield aliases
logic ADA_EN;
assign ADA_EN = CRAM.ADA[0];

logic AD_BOOL;
assign AD_BOOL = CRAM.AD[1];

logic [0:5] SPEC;
assign SPEC = CRAM.DISP;

logic [0:8] DIAG_FUNC;
assign DIAG_FUNC = CRAM.MAGIC;

logic [0:5] SKIP;
assign SKIP = CRAM.COND;
