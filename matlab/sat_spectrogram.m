function varargout = sat_spectrogram(x,window,noverlap,nfft,fs,npol)

if length(window) == 1
    window = hanning(window);
end

% Window length
nwind = length(window);
nx = length(x);

% Make x and win into columns
x = x(:); 
win = window(:); 

% Determine the number of columns of the STFT output (i.e., the S output)
ncol = fix((nx-noverlap)/(nwind-noverlap));

%
% Pre-process X
%
colindex = 1 + (0:(ncol-1))*(nwind-noverlap);
rowindex = (1:nwind)';
xin = zeros(nwind,ncol);

% Put x into columns of xin with the proper offset
xin(:) = x(rowindex(:,ones(1,ncol))+colindex(ones(nwind,1),:)-1);

% Remove polynomial
if npol > -1
    for ic=1:ncol
        p = polyfit(1:nwind,squeeze(xin(:,ic))', npol);
        xin(:,ic) = xin(:,ic) - polyval(p, 1:nwind)';
    end
end

% Apply the window to the array of offset signal segments.
xin = win(:,ones(1,ncol)).*xin;

%
% Compute the raw STFT with the appropriate algorithm
%
freqvecspecified = false;
if length(nfft) > 1, freqvecspecified = true; end

[y,f] = computeDFT(xin,nfft,fs);
if ~freqvecspecified
    f = psdfreqvec('npts',nfft,'Fs',fs,'Range','half');
    y = y(1:length(f),:);
end

% colindex already takes into account the noverlap factor; Return a T
% vector whose elements are centered in the segment.
t = ((colindex-1)+((nwind)/2)')/fs; 

% Frequency vector was specified, return and plot two-sided PSD
options.range = 'onesided';
if freqvecspecified, options.range = 'twosided'; end

esttype = 'psd';
switch nargout,
    case 0,
        % Use surface to display spectrogram
        [Pxx,W] = compute_PSD(win,y,nfft,f,options,fs,esttype);
        imagesc(t/60/60,f*1e3,10*log10(Pxx));
        ylabel('mHz');
        xlabel('Time (hours)');
        set(gca,'YDir','Normal')
    case 1,
        varargout = {y};
    case 2,
        varargout = {y,f};
    case 3,
        varargout = {y,f,t};
    case 4,
        Pxx = compute_PSD(win,y,nfft,f,options,fs,esttype);
        varargout = {y,f,t,Pxx};
end

% -------------------------------------------------------------------------
function [Pxx,W] = compute_PSD(win,y,nfft,f,options,Fs,esttype)
% Evaluate the window normalization constant.  A 1/N factor has been
% omitted since it will cancel below.
U = win'*win;     % Compensates for the power of the window.
Sxx = y.*conj(y)/U; % Auto spectrum.

% The computepsd function expects NFFT to be a scalar
if length(nfft) > 1, nfft = length(nfft); end

% Compute the one-sided or two-sided PSD [Power/freq]. Also compute
% the corresponding half or whole power spectrum [Power].
[Pxx,W] = computepsd(Sxx,f,options.range,nfft,Fs,esttype);


function [Xx,f] = computeDFT(xin,nfft,varargin)
%COMPUTEDFT Computes DFT using FFT or Goertzel
%   This function is used to calculate the DFT of a signal using the FFT 
%   or the Goertzel algorithm. 
%
%   [XX,F] = COMPUTEDFT(XIN,NFFT) where NFFT is a scalar and computes the 
%   DFT XX using FFT. F is the frequency points at which the XX is 
%   computed and is of length NFFT.
%
%   [XX,F] = COMPUTEDFT(XIN,F) where F is a vector with atleast two 
%   elements computes the DFT XX using the Goertzel algorithm. 
%
%   [XX,F] = COMPUTEDFT(...,Fs) returns the frequency vector F (in hz)
%   where Fs is the sampling frequency
%
%   Inputs:
%   XIN is the input signal
%   NFFT if a scalar corresponds to the number of FFT points used to 
%   calculate the DFT using FFT.
%   NFFT if a vector corresponds to the frequency points at which the DFT
%   is calculated using goertzel.
%   FS is the sampling frequency 

% Copyright 2006-2010 The MathWorks, Inc.

% [1] Oppenheim, A.V., and R.W. Schafer, Discrete-Time Signal Processing,
% Prentice-Hall, Englewood Cliffs, NJ, 1989, pp. 713-718.
% [2] Mitra, S. K., Digital Signal Processing. A Computer-Based Approach.
% 2nd Ed. McGraw-Hill, N.Y., 2001.

error(nargchk(2,3,nargin,'struct'));
if nargin > 2,
    Fs = varargin{1};
else
    Fs = 2*pi;
end

nx = size(xin,1);

if length(nfft) > 1, 
    isfreqVector = true; 
else 
    isfreqVector = false;
end

if ~isfreqVector,
    [Xx,f] = computeDFTviaFFT(xin,nx,nfft,Fs);
else
    [Xx,f] = computeDFTviaGoertzel(xin,nfft,Fs);
end
    
%-------------------------------------------------------------------------
function [Xx,f] = computeDFTviaFFT(xin,nx,nfft,Fs)
% Use FFT to compute raw STFT and return the F vector.

% Handle the case where NFFT is less than the segment length, i.e., "wrap"
% the data as appropriate.
xin_ncol = size(xin,2);
xw = zeros(nfft,xin_ncol);
if nx > nfft,
    for j = 1:xin_ncol, 
        xw(:,j) = datawrap(xin(:,j),nfft);
    end
else
    xw = xin;
end

Xx = fft(xw,nfft);
f = psdfreqvec('npts',nfft,'Fs',Fs);
%--------------------------------------------------------------------------
function [Xx,f] = computeDFTviaGoertzel(xin,freqvec,Fs)
% Use Goertzel to compute raw DFT and return the F vector.

f = freqvec(:);
f = mod(f,Fs); % 0 <= f < = Fs
nfld = floor(freqvec(:)/Fs);
xm = size(xin,1); % NFFT

% Indices used by the Goertzel function (see equation 11.1 pg. 755 of [2])
fscaled = f/Fs*xm+1;
k = round(fscaled);

% shift for each frequency from default xm length grid
deltak = fscaled-k;

tempk = k;
% If k > xm, fold over to the 1st bin
k(tempk > xm) = 1;
nfld = nfld + (tempk > xm); % Make nfld reflect fold in k because of round

n = (0:xm-1)';
Xx = zeros(size(k,1),size(xin,2));
for kindex = 1:length(k)
    % We need to evaluate the DFT at the requested frequency instead of a
    % neighboring frequency that lies on the grid obtained with xm number
    % of points in the 0 to fs range. We do that by giving a complex phase
    % to xin equal to the offset from the frequency to its nearest neighbor
    % on the grid. This phase translates into a shift in the DFT by the
    % same amount. The Xx(k) then is the DFT at (k+deltak).
    
    % apply kernal to xin so as to evaluate DFT at k+deltak)
    kernel = exp(-1i*2*pi*deltak(kindex)/xm*n);
    xin_phaseshifted = xin.*repmat(kernel,1,size(xin,2));
    
    Xx(kindex,:) = goertzel(xin_phaseshifted,k(kindex));
end

% DFT computed at exactly the frequencies it was requested for
f = freqvec(:);

%-----------------------------
